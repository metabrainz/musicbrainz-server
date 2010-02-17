package MusicBrainz::Server::Controller::User::Collection;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub _ensure_collection
{
    my ($self, $c) = @_;

    my $collection_id = $c->stash->{user_collection};
    unless ($collection_id) {
        $collection_id = $c->model('Collection')->create_collection($c->user);
        $c->stash->{user_collection} = $collection_id;
        $c->session->{collection} = $collection_id;
    }

    return $collection_id;
}

sub add : Local
{
    my ($self, $c) = @_;

    my $release_id = $c->request->params->{id};
    my $collection_id = $self->_ensure_collection($c);

    $c->model('Collection')->add_release_to_collection($collection_id, $release_id);

    my $redirect = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($redirect);
    $c->detach;
}

sub remove : Local
{
    my ($self, $c) = @_;

    my $release_id = $c->request->params->{id};
    my $collection_id = $self->_ensure_collection($c);

    $c->model('Collection')->remove_release_from_collection($collection_id, $release_id);

    my $redirect = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($redirect);
    $c->detach;
}

sub view : Local Args(1) RequireAuth
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name);

    $c->detach('/error_404')
        if (!defined $user);

    $c->detach ('/error_403')
        if ($user->id != $c->user->id);


    my $releases;
    my $collection_id = $c->stash->{user_collection};
    my $order = $c->req->params->{order} || 'date';

    if ($collection_id) {
        $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_collection($collection_id, shift, shift, $order);
        });
        $c->model('ArtistCredit')->load(@$releases);
        $c->model('Medium')->load_for_releases(@$releases);
        $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
        $c->model('Country')->load(@$releases);
        $c->model('ReleaseLabel')->load(@$releases);
        $c->model('Label')->load(map { $_->all_labels } @$releases);
    }

    $c->stash(
        user => $user,
        order => $order,
        releases => $releases,
        template => 'user/collection.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
