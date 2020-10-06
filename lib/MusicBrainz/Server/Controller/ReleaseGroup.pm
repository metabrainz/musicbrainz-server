package MusicBrainz::Server::Controller::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASEGROUP_EDIT
    $EDIT_RELEASEGROUP_MERGE
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_RELEASEGROUP_SET_COVER_ART
    %ENTITIES
);
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Entity::Util::Release qw( group_by_release_status );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'ReleaseGroup',
    entity_name     => 'rg',
    relationships   => { all => ['show'], cardinal => ['edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {copy_stash => [{from => 'releases_jsonld', to => 'releases'}, 'top_tags']},
                  aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_name => 'rg',
    entity_type => 'release_group',
};

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';

__PACKAGE__->config(
    namespace   => 'release_group',
);

sub base : Chained('/') PathPart('release-group') CaptureArgs(0) { }

after 'load' => sub {
    my ($self, $c) = @_;

    my $rg = $c->stash->{rg};
    my $returning_jsonld = $self->should_return_jsonld($c);

    unless ($returning_jsonld) {
        $c->model('ReleaseGroup')->load_meta($rg);

        if ($c->user_exists) {
            $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, $rg);
        }

        $c->stash( can_delete => $c->model('ReleaseGroup')->can_delete($rg->id) );
    }

    $c->model('ReleaseGroupType')->load($rg);
    $c->model('ArtistCredit')->load($rg);
    $c->model('Artwork')->load_for_release_groups($rg);
};

sub show : Chained('load') PathPart('') {
    my ($self, $c) = @_;

    my $rg = $c->stash->{rg};

    my $releases = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_release_group($rg->id, shift, shift);
    });

    $c->model('Release')->load_related_info(@$releases);
    $c->model('Release')->load_meta(@$releases);
    $c->model('ArtistCredit')->load(@$releases);
    $c->model('ReleaseStatus')->load(@$releases);

    my %props = (
        numberOfRevisions => $c->stash->{number_of_revisions},
        pager             => serialize_pager($c->stash->{pager}),
        releases          => [map { to_json_array($_) } @{group_by_release_status(@$releases)}],
        releaseGroup      => $c->stash->{rg}->TO_JSON,
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'release_group/ReleaseGroupIndex',
        component_props => \%props,
        current_view => 'Node',
        releases_jsonld   => { items => $releases },
    );
}

after [qw( show collections details tags ratings aliases )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
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
            $c->stash(
                initial_artist => $artist,
                # These added so the entity tabs will appear properly
                entity => $artist,
                entity_properties => $ENTITIES{artist}
            );
            return ( item => $rg );
        }
        else {
            return ();
        }
    },
    dialog_template => 'release_group/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'ReleaseGroup',
    edit_type      => $EDIT_RELEASEGROUP_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_RELEASEGROUP_MERGE,
};

sub forward_merge : Chained('/') PathPart('release-group/merge') {
    # Since Role::Merge is generic it uses release_group rather than release-group
    # like elsewhere. We should make sure nothing breaks if we expect release-group somewhere
    my ($self, $c) = @_;
    $c->forward('/release_group/merge');
}

sub _merge_load_entities
{
    my ($self, $c, @rgs) = @_;

    $c->model('ArtistCredit')->load(@rgs);
    $c->model('ReleaseGroup')->load_meta(@rgs);
    $c->model('ReleaseGroupType')->load(@rgs);
};

sub set_cover_art : Chained('load') PathPart('set-cover-art') Args(0) Edit
{
    my ($self, $c, $id) = @_;

    my $entity = $c->stash->{entity};
    return unless $entity->can_set_cover_art;

    my ($releases, undef) = $c->model('Release')->find_by_release_group(
        $entity->id);
    $c->model('Release')->load_related_info(@$releases);
    $c->model('Release')->load_meta(@$releases);
    $c->model('ArtistCredit')->load(@$releases);

    my @non_darkened_releases = grep { $_->may_have_cover_art } @$releases;
    my $artwork = $c->model('Artwork')->find_front_cover_by_release(@non_darkened_releases);
    $c->model('CoverArtType')->load_for(@$artwork);
    my %artwork_map = map { $_->release->id => $_ } @$artwork;

    my $cover_art_release = $entity->cover_art ? $entity->cover_art->release : undef;
    my $form = $c->form(form => 'ReleaseGroup::SetCoverArt', init_object => {
        release => $cover_art_release ? $cover_art_release->gid : undef });

    my $form_valid = $c->form_posted_and_valid($form);

    my $selected_release = $form_valid
        ? $c->model('Release')->get_by_gid($form->field('release')->value)
        : $cover_art_release;

    $c->stash({
        form => $form,
        artwork => \%artwork_map,
        all_releases => $releases,
        selected_release => $selected_release,
        });

    if ($form_valid)
    {
        my $edit;
        $c->model('MB')->with_transaction(sub {
            $edit = $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELEASEGROUP_SET_COVER_ART,
                release => $selected_release,
                entity => $entity,
            );
        });

        if ($edit)
        {
            $c->response->redirect(
                $c->uri_for_action($self->action_for('show'), [ $entity->gid ]));
            $c->detach;
        }
    }
}

1;

=head1 NAME

MusicBrainz::Server::Controller::ReleaseGroup - controller for release groups

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles
Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
