package MusicBrainz::Server::ControllerBase::WS::1;

use Moose;
use Readonly;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::Exceptions;
use MusicBrainz::Server::WebService::XMLSerializerV1;
use Scalar::Util qw( looks_like_number );
use Try::Tiny;

with 'MusicBrainz::Server::Controller::Role::Profile' => {
    threshold => DBDefs->PROFILE_WEB_SERVICE()
};

with 'MusicBrainz::Server::Controller::Role::CORS';
with 'MusicBrainz::Server::Controller::Role::ETags';

has 'model' => (
    isa => 'Str',
    is  => 'ro',
);

with 'MusicBrainz::Server::WebService::Format' =>
{
    serializers => [
        'MusicBrainz::Server::WebService::XMLSerializerV1',
    ]
};


sub apply_rate_limit
{
    my ($self, $c, $key) = @_;
    $key ||= "ws ip=" . $c->request->address;

    my $r;

    $r = $c->model('RateLimiter')->check_rate_limit('ws ua=' . ($c->req->user_agent || ''));
    if ($r && $r->is_over_limit) {
        $c->response->status(HTTP_SERVICE_UNAVAILABLE);
        $c->res->content_type("text/plain; charset=utf-8");
        $c->res->headers->header(
            'X-Rate-Limited' => sprintf('%.1f %.1f %d', $r->rate, $r->limit, $r->period)
        );
        $c->res->body(
            $c->stash->{serializer}->output_error(
                "Your requests are being throttled by MusicBrainz because the ".
                "application you are using has not identified itself.  Please ".
                "update your application, and see ".
                "http://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting for more ".
                "information."
            )
        );
        $c->detach;
    }


    $r = $c->model('RateLimiter')->check_rate_limit($key);
    if ($r && $r->is_over_limit) {
        $c->response->status(HTTP_SERVICE_UNAVAILABLE);
        $c->res->content_type("text/plain; charset=utf-8");
        $c->res->headers->header(
            'X-Rate-Limited' => sprintf('%.1f %.1f %d', $r->rate, $r->limit, $r->period)
        );
        $c->response->body(
            "Your requests are exceeding the allowable rate limit (" . $r->msg . ")\015\012" .
            "Please see http://wiki.musicbrainz.org/XMLWebService for more information.\015\012"
        );
        return 0;
    }

    $r = $c->model('RateLimiter')->check_rate_limit('ws global');
    if ($r && $r->is_over_limit) {
        $c->response->status(HTTP_SERVICE_UNAVAILABLE);
        $c->res->content_type("text/plain; charset=utf-8");
        $c->res->headers->header(
            'X-Rate-Limited' => sprintf('%.1f %.1f %d', $r->rate, $r->limit, $r->period)
        );
        $c->response->body(
            "The MusicBrainz web server is currently busy.\015\012" .
            "Please try again later.\015\012"
        );
        return 0;
    }

    return 1;
}

sub authenticate
{
    my ($self, $c, $scope) = @_;

    $c->authenticate({}, 'musicbrainz.org');
    $self->forbidden($c) unless $c->user->is_authorized($scope);
}

sub begin : Private {}
sub auto : Private {
    my ($self, $c) = @_;

    $c->stash->{data} = {};
    my $continue = try {
        $self->validate($c) or $c->detach('bad_req');
        return 1;
    }
    catch {
        my $err = $_;
        if(eval { $err->isa('MusicBrainz::Server::WebService::Exceptions::UnknownIncParameter') }) {
            $self->bad_req($c, $err->message);
        }
        return 0;
    };

    return $continue && $self->apply_rate_limit($c);
}

sub root : Chained('/') PathPart('ws/1') CaptureArgs(0) { }

sub search : Chained('root') PathPart('')
{
    my ($self, $c) = @_;

    my $limit = looks_like_number($c->req->query_params->{limit}) ? int($c->req->query_params->{limit}) : 25;
    $limit = 25 if $limit < 1 || $limit > 100;

    my $offset = looks_like_number($c->req->query_params->{offset}) ? int($c->req->query_params->{offset}) : 0;
    $offset = 0 if $offset < 0;

    try {
        my $body = $c->model('Search')->xml_search(
            %{ $c->req->query_params },

            limit   => $limit,
            offset  => $offset,
            type    => model_to_type($self->model),
            version => 1,
        );
        $c->res->body($body);
    }
    catch {
        my $err = $_;
        if (blessed($err) && $err->isa('MusicBrainz::Server::Exceptions::InvalidSearchParameters')) {
            $c->res->body($err->message);
            $c->res->status(HTTP_BAD_REQUEST);
        }
        elsif (blessed($err) && $err->isa('HTTP::Response')) {
            $c->res->body("Could not retrieve sub-document page from search server. Error: " . $err->status_line);
            $c->res->status(HTTP_SERVICE_UNAVAILABLE);
        }
        else {
            die $err;
        }
    };

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
}

# Don't render with TT
sub end : Private { }

sub bad_req : Private
{
    my ($self, $c, $error) = @_;
    $c->res->status(HTTP_BAD_REQUEST);
    $c->res->content_type("text/plain; charset=utf-8");
    $c->res->body($c->stash->{serializer}->output_error($error || $c->stash->{error}));
    $c->detach;
}

sub forbidden : Private
{
    my ($self, $c) = @_;
    $c->res->status(HTTP_FORBIDDEN);
    $c->res->content_type("text/plain; charset=utf-8");
    $c->res->body($c->stash->{serializer}->output_error("You are not authorized to access this resource."));
    $c->detach;
}

sub deny_readonly : Private
{
    my ($self, $c) = @_;
    if(DBDefs->DB_READ_ONLY) {
        $c->res->status(HTTP_SERVICE_UNAVAILABLE);
        $c->res->content_type("text/plain; charset=utf-8");
        $c->res->body($c->stash->{serializer}->output_error("The database is currently in readonly mode and cannot handle your request"));
        $c->detach;
    }
}


sub load : Chained('root') PathPart('') CaptureArgs(1)
{
    my ($self, $c, $gid) = @_;

    if (!is_guid($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $entity = $c->model($self->model)->get_by_gid($gid)
        or $c->detach('not_found');

    $c->stash->{entity} = $entity;
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->res->status(404);
    $c->detach;
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
