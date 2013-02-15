package MusicBrainz::Server::Controller::WS::2::URL;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     url => {
                         method   => 'GET',
                         linked   => [ qw(resource) ],
                         inc      => [ qw(_relations) ],
                         optional => [ qw(fmt) ],
     },
     url => {
                         method   => 'GET',
                         inc      => [ qw(_relations) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'URL'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('url') CaptureArgs(0) { }

sub url : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $url = $c->stash->{entity};

    return unless defined $url;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($url);

    $self->url_toplevel ($c, $stash, $url);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('url', $url, $c->stash->{inc}, $stash));
}

sub url_toplevel
{
    my ($self, $c, $stash, $url) = @_;

    my $opts = $stash->store ($url);

    $self->load_relationships($c, $stash, $url);
}

sub url_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };

    my $url;
    if ($resource eq 'resource')
    {
        ($url) = $c->model('URL')->find_by_url($id);
        $c->detach('not_found') unless ($url);
    }

    my $stash = WebServiceStash->new;

    $self->url_toplevel ($c, $stash, $url);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('url', $url, $c->stash->{inc}, $stash));
}

sub url_search : Chained('root') PathPart('url') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('url_browse') if ($c->stash->{linked});
}


__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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

