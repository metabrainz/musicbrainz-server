package MusicBrainz::Server::Controller::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE $EDIT_RELEASEGROUP_EDIT $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Form::Confirm;

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::DetailsRole';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

__PACKAGE__->config(
    model       => 'ReleaseGroup',
    entity_name => 'rg',
    namespace   => 'release_group',
);

sub base : Chained('/') PathPart('release-group') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $rg = $c->stash->{rg};
    $c->model('ReleaseGroup')->load_meta($rg);
    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, $rg);
    }
    $c->model('ReleaseGroupType')->load($rg);
    $c->model('ArtistCredit')->load($rg);
};

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $releases = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_release_group($c->stash->{rg}->id, shift, shift);
    });

    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    $c->model('Country')->load(@$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->model('Label')->load(map { $_->all_labels } @$releases);

    $c->stash(
        template => 'release_group/index.tt',
        releases => $releases
    );
}

sub delete : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    my $rg = $c->stash->{rg};
    my $can_delete = 1;
    
    return unless $can_delete;
    my $form = $c->form( form => 'Confirm' );
    $c->stash( can_delete => $can_delete );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params) )
    {
        my $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            edit_type => $EDIT_RELEASEGROUP_DELETE,
            release_group_id => $rg->id
        );

        $c->response->redirect($c->uri_for_action('/release_group/show', [ $rg->gid ]));
        $c->detach;
    }
}

sub edit : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    my $rg = $c->stash->{rg};

    my $form = $c->form( form => 'ReleaseGroup', init_object => $rg );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            edit_type => $EDIT_RELEASEGROUP_EDIT,
            release_group => $rg,
            (map { $_ => $form->field($_)->value }
                 grep { $form->field($_)->has_value }
                     qw( type_id name comment artist_credit ))
        );

        $c->response->redirect($c->uri_for_action('/release_group/show', [ $rg->gid ]));
    }
}

sub merge : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $old = $c->stash->{rg};

    if ($c->req->query_params->{dest}) {
        my $new = $c->model('ReleaseGroup')->get_by_gid($c->req->query_params->{dest});
        $c->model('ArtistCredit')->load($new);

        my $form = $c->form( form => 'Confirm' );
        $c->stash(
            template => 'release_group/merge_confirm.tt',
            old_rg => $old,
            new_rg => $new
        );

        if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
            my $edit = $c->model('Edit')->create(
                editor_id => $c->user->id,
                edit_type => $EDIT_RELEASEGROUP_MERGE,
                old_release_group_id => $old->id,
                new_release_group_id => $new->id
            );

            $c->response->redirect($c->uri_for_action('/release_group/show', [ $new->gid ]));
        }
        $c->stash( template => 'release_group/merge_confirm.tt' );
    }
    else {
        my $query = $c->form( query_form => 'Search::Query', name => 'filter' );
        if ($query->submitted_and_valid($c->req->params)) {
            my $results = $self->_load_paged($c, sub {
                    $c->model('DirectSearch')->search('release_group', $query->field('query')->value, shift, shift)
                });
            $c->model('ArtistCredit')->load(map { $_->entity } @$results);

            $c->stash(
                search_results => $results
            );
        }
        $c->stash( template => 'release_group/merge_search.tt' );
    }
}

1;

=head1 NAME

MusicBrainz::Server::Controller::ReleaseGroup - controller for release groups

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
