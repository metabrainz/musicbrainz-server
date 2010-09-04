package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw( $DARTIST_ID $DLABEL_ID );
use MusicBrainz::Server::WebService::JSONSerializer;
use MusicBrainz::Server::WebService::Validator;
use MusicBrainz::Server::Filters;
use MusicBrainz::Server::Data::Search;
use Readonly;
use Data::OptList;

# This defines what options are acceptable for WS calls
my $ws_defs = Data::OptList::mkopt([
     artist => {
         method   => 'GET',
         required => [ qw(q) ],
         optional => [ qw(limit timestamp) ]
     },
     label => {
         method   => 'GET',
         required => [ qw(q) ],
         optional => [ qw(limit timestamp) ]
     },
     recording => {
         method   => 'GET',
         required => [ qw(q) ],
         optional => [ qw(a r limit timestamp) ]
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

Readonly my %serializers => (
    json => 'MusicBrainz::Server::WebService::JSONSerializer',
);

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub begin : Private
{
}

sub end : Private
{
}

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c, \%serializers) or $c->detach('bad_req');
}

sub _autocomplete_entity {
    my ($self, $c, $type, $filter) = @_;

    my $query = $c->stash->{args}->{q};
    my $limit = $c->stash->{args}->{limit} || 10;

    unless ($query) {
        $c->detach('bad_req');
    }

    my @entities = $c->model($type)->autocomplete_name($query, $limit);
    @entities = grep { $_->id != $filter } @entities;

    # FIXME: I think results should be post-processed to sort the entries
    # which match the case of the query above other results.  The sortname
    # should also be taken into account for those entities which have them.
    # -- warp.

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('autocomplete_name', \@entities));
}

sub artist : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'Artist', $DARTIST_ID);
}

sub label : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'Label', $DLABEL_ID);
}

sub _serialize_release_groups
{
    my (@rgs) = @_;

    my @ret;

    for (@rgs)
    {
        push @ret, { 'name' => $_->name, 'gid' => $_->gid, };
    }

    return \@ret;
}

sub recording : Chained('root') PathPart('recording') Args(0)
{
    my ($self, $c) = @_;

    my $query = MusicBrainz::Server::Data::Search::escape_query ($c->stash->{args}->{q});
    my $artist = MusicBrainz::Server::Data::Search::escape_query ($c->stash->{args}->{a} || '');
    my $limit = $c->stash->{args}->{limit} || 10;

    my $response = $c->model ('Search')->external_search (
        $c, 'recording', "$query artist:\"$artist\"", $limit, 1, 1);

    my $pager = $response->{pager};

    my @entities;
    for my $result (@{ $response->{results} })
    {
        my @rgs = $c->model ('ReleaseGroup')->find_by_release_gids (
            map { $_->gid } @{ $result->{extra} });

        push @entities, {
            gid => $result->{entity}->gid,
            id => $result->{entity}->id,
            length => MusicBrainz::Server::Filters::format_length ($result->{entity}->length),
            name => $result->{entity}->name,
            artist => $result->{entity}->artist_credit->name,
            releasegroups => _serialize_release_groups (@rgs),
        };
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', \@entities));
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $serializers{$self->get_default_serialization_type}->new();
    $c->stash->{error} = "Invalid resource: $resource.";
    $c->detach('bad_req');
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
