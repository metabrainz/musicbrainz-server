package MusicBrainz::Server::Controller::Collection;
use Moose;
use Scalar::Util qw( looks_like_number );

BEGIN { extends 'MusicBrainz::Server::Controller' };

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'collection',
    model       => 'Collection',
};
with 'MusicBrainz::Server::Controller::Role::Subscribe';

use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );

sub base : Chained('/') PathPart('collection') CaptureArgs(0) { }
after 'load' => sub
{
    my ($self, $c) = @_;
    my $collection = $c->stash->{collection};

    if ($c->user_exists) {
        $c->stash->{subscribed} = $c->model('Collection')->subscription->check_subscription(
            $c->user->id, $collection->id);
    }

    # Load editor
    $c->model('Editor')->load($collection);

    $c->stash(
        my_collection => $c->user_exists && $c->user->id == $collection->editor_id
    )
};

sub own_collection : Chained('load') CaptureArgs(0) {
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};
    $c->forward('/user/do_login') if !$c->user_exists;
    $c->detach('/error_403') if !$collection->public && $c->user->id != $collection->editor_id;
}

sub add : Chained('own_collection') RequireAuth
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};
    my $release_id = $c->request->params->{release};

    my $release = $c->model('Release')->get_by_id($release_id);

    $c->model('Collection')->add_releases_to_collection($collection->id, $release_id);

    $c->response->redirect($c->req->referer || $c->uri_for_action('/release/show', [ $release->gid ]));
    $c->detach;
}

sub remove : Chained('own_collection') RequireAuth
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};
    my $release_id = $c->request->params->{release};

    my $release = $c->model('Release')->get_by_id($release_id);

    $c->model('Collection')->remove_releases_from_collection($collection->id, $release_id);

    $c->response->redirect($c->req->referer || $c->uri_for_action('/release/show', [ $release->gid ]));
    $c->detach;
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    if ($c->form_posted && $c->stash->{my_collection}) {
        my $remove_params = $c->req->params->{remove};
        $c->model('Collection')->remove_releases_from_collection(
            $collection->id,
            grep { looks_like_number($_) }
                ref($remove_params) ? @$remove_params : ($remove_params)
        );
    }

    $self->own_collection($c) if !$collection->public;

    my $order = $c->req->params->{order} || 'date';

    my $releases = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_collection($collection->id, shift, shift, $order);
    });
    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    load_release_events($c, @$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->model('Label')->load(map { $_->all_labels } @$releases);
    $c->model('ReleaseGroup')->load(@$releases);
    $c->model('ReleaseGroup')->load_meta(map { $_->release_group } @$releases);
    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, map { $_->release_group } @$releases);
    }
    $c->stash(
        collection => $collection,
        order => $order,
        releases => $releases,
        template => 'collection/index.tt'
    );
}

sub edits : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;

    $self->_list_edits($c);
}

sub open_edits : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;

    $self->_list_edits($c, $STATUS_OPEN);

    $c->stash(
        template => model_to_type( $self->{model} ) . '/edits.tt'
    );
}

sub _list_edits {
    my ($self, $c, $status) = @_;

    my $edits  = $self->_load_paged($c, sub {
        my ($limit, $offset) = @_;
        $c->model('Edit')->find_by_collection($c->stash->{collection}->id, $limit, $offset, $status);
    });

    $c->model('Edit')->load_all(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);

    $c->stash(
        edits => $edits,
    );
}

sub _form_to_hash
{
    my ($self, $form) = @_;

    return map { $form->field($_)->name => $form->field($_)->value } $form->edit_field_names;
}

sub create : Local RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Collection' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my %insert = $self->_form_to_hash($form);

        my $collection = $c->model('Collection')->insert($c->user->id, \%insert);

        my $params = $c->req->params;
        if (exists $params->{"release"}) {
            my $release_id = $params->{"release"};
            $c->model('Collection')->add_releases_to_collection($collection->id, $release_id);
        }

        $c->response->redirect(
            $c->uri_for_action($self->action_for('show'), [ $collection->gid ]));
    }
}

sub edit : Chained('own_collection') RequireAuth
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    my $form = $c->form( form => 'Collection', init_object => $collection );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my %update = $self->_form_to_hash($form);

        $c->model('Collection')->update($collection->id, \%update);

        $c->response->redirect(
            $c->uri_for_action($self->action_for('show'), [ $collection->gid ]));
    }
}

sub delete : Chained('own_collection') RequireAuth
{
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    if ($c->form_posted) {
        $c->model('Collection')->delete($collection->id);

        $c->response->redirect(
            $c->uri_for_action('/user/collections', [ $c->user->name ]));
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 Sean Burke

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
