package MusicBrainz::Server::Controller::WS::2::URL;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::ControllerBase::WS::2';

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     url => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     url => {
                         method   => 'GET',
                         linked   => [ qw(resource) ],
                         inc      => [ qw(_relations) ],
                         optional => [ qw(fmt) ],
     },
     url => {
                         action   => '/ws/2/url/lookup',
                         method   => 'GET',
                         inc      => [ qw(_relations) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'URL',
};

Readonly our $MAX_RESOURCE_PARAMS => 100;

sub base : Chained('root') PathPart('url') CaptureArgs(0) { }

sub url_toplevel
{
    my ($self, $c, $stash, $urls) = @_;

    $self->load_relationships($c, $stash, @{$urls});
}

sub url_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };

    my $is_list = ref($id) eq 'ARRAY';
    my @urls;
    if ($resource eq 'resource') {
        if ($is_list) {
            if (scalar(@$id) > $MAX_RESOURCE_PARAMS) {
                @$id = @$id[0 .. ($MAX_RESOURCE_PARAMS - 1)];
            }
            @urls = $c->model('URL')->find_by_urls($id);
        } else {
            my $url = $c->model('URL')->find_by_url($id);
            $c->detach('not_found') unless $url;
            @urls = $url;
        }
    }

    my $stash = WebServiceStash->new;
    $self->url_toplevel($c, $stash, \@urls);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');

    if ($is_list) {
        my $url_list = $self->make_list(\@urls, scalar @urls, 0);
        $c->res->body($c->stash->{serializer}->serialize('url-list', $url_list, $c->stash->{inc}, $stash));
    } else {
        $c->res->body($c->stash->{serializer}->serialize('url', $urls[0], $c->stash->{inc}, $stash));
    }
}

sub url_search : Chained('root') PathPart('url') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('url_browse') if ($c->stash->{linked});
    $self->_search($c, 'url');
}


__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

