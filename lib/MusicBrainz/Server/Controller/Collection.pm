package MusicBrainz::Server::Controller::Collection;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

__PACKAGE__->config(
    entity_name => 'collection',
    model       => 'Collection',
);

sub base : Chained('/') PathPart('collection') CaptureArgs(0) { }
after 'load' => sub
{
    my ($self, $c) = @_;
    my $collection = $c->stash->{collection};

    # Load editor
    $c->model('Editor')->load($collection);
};

sub add : Local Args(1)
{
    my ($self, $c, $collection_id) = @_;

    my $release_id = $c->request->params->{id};

    $c->model('Collection')->add_release_to_collection($collection_id, $release_id);

    my $redirect = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($redirect);
    $c->detach;
}

sub remove : Local Args(1)
{
    my ($self, $c, $collection_id) = @_;

    my $release_id = $c->request->params->{id};

    $c->model('Collection')->remove_release_from_collection($collection_id, $release_id);

    my $redirect = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($redirect);
    $c->detach;
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    my $user = $collection->editor;
    $c->detach('/error_404')
        if ((!$c->user_exists || $c->user->id != $user->id) && !$collection->public);

    my $order = $c->req->params->{order} || 'date';

    my $releases = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_collection($collection->id, shift, shift, $order);
    });
    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    $c->model('Country')->load(@$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->model('Label')->load(map { $_->all_labels } @$releases);

    $c->stash(
        collection => $collection,
        order => $order,
        releases => $releases
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
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
