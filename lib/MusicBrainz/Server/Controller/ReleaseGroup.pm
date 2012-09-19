package MusicBrainz::Server::Controller::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASEGROUP_DELETE
    $EDIT_RELEASEGROUP_EDIT
    $EDIT_RELEASEGROUP_MERGE
    $EDIT_RELEASEGROUP_CREATE
);
use MusicBrainz::Server::Entity::Util::Release qw( group_by_release_status );
use MusicBrainz::Server::Form::Confirm;

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'ReleaseGroup',
    entity_name => 'rg',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';

__PACKAGE__->config(
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
    $c->stash( can_delete => $c->model('ReleaseGroup')->can_delete($rg->id) );
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
    $c->model('ReleaseStatus')->load(@$releases);
    $c->model('Relationship')->load($c->stash->{rg});

    $c->stash(
        template => 'release_group/index.tt',
        releases => group_by_release_status(@$releases)
    );
}

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_RELEASEGROUP_DELETE,
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    path           => '/release-group/create',
    form           => 'ReleaseGroup',
    edit_type      => $EDIT_RELEASEGROUP_CREATE,
    edit_arguments => sub {
        my ($self, $c) = @_;
        my $artist_gid = $c->req->query_params->{artist};
        if ( my $artist = $c->model('Artist')->get_by_gid($artist_gid) ) {
            my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new(
                artist_credit => ArtistCredit->from_artist($artist)
            );
            $c->stash( initial_artist => $artist );
            return ( item => $rg );
        }
        else {
            return ();
        }
    }
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'ReleaseGroup',
    edit_type      => $EDIT_RELEASEGROUP_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_RELEASEGROUP_MERGE,
    confirmation_template => 'release_group/merge_confirm.tt',
    search_template       => 'release_group/merge_search.tt',
};

after 'merge' => sub
{
    my ($self, $c) = @_;

    $c->model('ReleaseGroup')->load_meta(@{ $c->stash->{to_merge} });
    $c->model('ReleaseGroupType')->load(@{ $c->stash->{to_merge} });
    $c->model('ArtistCredit')->load(
        $c->stash->{old}, $c->stash->{new}
    );
};

around '_merge_search' => sub
{
    my $orig = shift;
    my ($self, $c, $query) = @_;

    my $results = $self->$orig($c, $query);
    $c->model('ArtistCredit')->load(map { $_->entity } @$results);

    return $results;
};

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
