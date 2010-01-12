package MusicBrainz::Server::Controller::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASEGROUP_DELETE
    $EDIT_RELEASEGROUP_EDIT
    $EDIT_RELEASEGROUP_MERGE
    $EDIT_RELEASEGROUP_CREATE
);
use MusicBrainz::Server::Form::Confirm;

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::DetailsRole';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';

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
    if($c->model('ReleaseGroup')->can_delete($rg->id)) {
        $c->stash( can_delete => 1 );
        $self->edit_action($c,
            form => 'Confirm',
            type => $EDIT_RELEASEGROUP_DELETE,
            edit_args => { release_group => $rg },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action('/release_group/show', [ $rg->gid ]));
            }
        );
    }
}

sub create : Path('/release-group/create') RequireAuth
{
    my ($self, $c) = @_;
    my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new;
    my $artist_gid = $c->req->query_params->{artist};
    if ( my $artist = $c->model('Artist')->get_by_gid($artist_gid) ) {
        $rg->artist_credit(
            ArtistCredit->new(
                names => [
                    ArtistCreditName->new(
                        artist_id => $artist->id,
                        name => $artist->name,
                    )
                ]
            )
        );
    }

    $self->edit_action($c,
        form => 'ReleaseGroup',
        type => $EDIT_RELEASEGROUP_CREATE,
        item => $rg,
        on_creation => sub {
            my $edit = shift;
            $c->response->redirect(
                $c->uri_for_action('/release_group/show', [ $edit->release_group->gid ]));
        }
    );
}

sub edit : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    my $rg = $c->stash->{rg};
    $self->edit_action($c,
        form => 'ReleaseGroup',
        item => $rg,
        type => $EDIT_RELEASEGROUP_EDIT,
        edit_args => { release_group => $rg },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action('/release_group/show', [ $rg->gid ]));
        }
    );
}

sub merge : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $old = $c->stash->{rg};

    if ($c->req->query_params->{dest}) {
        my $new = $c->model('ReleaseGroup')->get_by_gid($c->req->query_params->{dest});
        $c->model('ArtistCredit')->load($new);

        $c->stash(
            template => 'release_group/merge_confirm.tt',
            old_rg => $old,
            new_rg => $new
        );

        $c->stash( template => 'release_group/merge_confirm.tt' );
        $self->edit_action($c,
            form => 'Confirm',
            type => $EDIT_RELEASEGROUP_MERGE,
            edit_args => {
                old_release_group_id => $old->id,
                new_release_group_id => $new->id
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action('/release_group/show', [ $new->gid ]));
            }
        );
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
