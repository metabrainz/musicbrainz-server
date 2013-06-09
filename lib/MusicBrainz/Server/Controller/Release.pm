package MusicBrainz::Server::Controller::Release;
use Moose;
use MusicBrainz::Server::Track;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'release',
    model       => 'Release',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Tag';

use List::Util qw( first );
use List::MoreUtils qw( part uniq );
use List::UtilsBy 'nsort_by';
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Constants qw( :edit_type );
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use Scalar::Util qw( looks_like_number );

use aliased 'MusicBrainz::Server::Entity::Work';

# A duration lookup has to match within this many milliseconds
use constant DURATION_LOOKUP_RANGE => 10000;

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for
working with Release entities

=head1 DESCRIPTION

This controller handles user interaction, both read and write, with
L<MusicBrainz::Server::Entity::Release> objects. This includes displaying
releases, editing releases and creating new releases.

=head1 METHODS

=head2 base

Base action to specify that all actions live in the C<label>
namespace

=cut

sub base : Chained('/') PathPart('release') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $c->model('Release')->load_meta($release);

    # Load release group
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);
    $c->model('Relationship')->load_subset([ 'url' ], $release->release_group);
    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, $release->release_group);
    }

    # FIXME: replace this with a proper MusicBrainz::Server::Entity::Artwork object
    my $prefix = DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . "/release/" . $release->gid;
    $c->stash->{release_artwork} = {
        image => $prefix.'/front',
        large_thumbnail => $prefix.'/front-500',
        small_thumbnail => $prefix.'/front-250'
    };

    # We need to load more artist credits in 'show'
    if ($c->action->name ne 'show') {
        $c->model('ArtistCredit')->load($release);
    }

    # The release editor loads this stuff on its own
    if ($c->action->name ne 'edit') {
        $c->model('ReleaseStatus')->load($release);
        $c->model('ReleasePackaging')->load($release);
        $c->model('Language')->load($release);
        $c->model('Script')->load($release);
        $c->model('ReleaseLabel')->load($release);
        $c->model('Label')->load($release->all_labels);
        $c->model('ReleaseGroupType')->load($release->release_group);
        $c->model('Medium')->load_for_releases($release);
        $c->model('MediumFormat')->load($release->all_mediums);
        load_release_events($c, $release);
    }
};

# Stuff that has the side bar and thus needs to display collection information
after [qw( cover_art add_cover_art edit_cover_art reorder_cover_art
           show collections details discids tags relationships )] => sub {
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    my @collections;
    my %containment;
    if ($c->user_exists) {
        # Make a list of collections and whether this release is contained in them
        @collections = $c->model('Collection')->find_all_by_editor($c->user->id);
        foreach my $collection (@collections) {
            $containment{$collection->id} = 1
                if ($c->model('Collection')->check_release($collection->id, $release->id));
        }
    }

    my @all_collections = $c->model('Collection')->find_all_by_release($release->id);

    $c->stash(
        collections => \@collections,
        containment => \%containment,
        all_collections => \@all_collections,
    );
};

after 'relationships' => sub
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $c->model('Relationship')->load($release->release_group);
};

sub discids : Chained('load')
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
    $c->model('CDTOC')->load(@medium_cdtocs);
    $c->stash( has_cdtocs => scalar(@medium_cdtocs) > 0 );
}

=head2 relations

Show all relationships attached to this release

=cut

sub relations : Chained('load')
{
    my ($self, $c) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
}

=head2 show

Display a release to the user.

This loads a release from the database (given a valid MBID or database row
ID) and displays it in full, including a summary of advanced relations,
tags, tracklisting, release events, etc.

=cut

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    my @mediums = $release->all_mediums;
    $c->model('Track')->load_for_mediums(@mediums);

    my @tracks = map { $_->all_tracks } @mediums;
    my @recordings = $c->model('Recording')->load(@tracks);
    $c->model('Recording')->load_meta(@recordings);
    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @recordings);
    }
    $c->model('ArtistCredit')->load($release, @tracks);

    $c->model('Relationship')->load(@recordings);
    $c->model('Relationship')->load(
        $release,
        grep { $_->isa(Work) } map { $_->target }
            map { $_->all_relationships } @recordings);

    $c->stash(
        template      => 'release/index.tt',
        show_artists  => $release->has_multiple_artists,
        combined_rels => $release->combined_track_relationships,
    );
}

=head2 show

Lookup a CD

Given a TOC, carry out a fuzzy TOC lookup and display the matches in a table

=cut

sub medium_sort
{
    ($a->medium->format_id || 99) <=> ($b->medium->format_id || 99)
        or
    ($a->medium->release->release_group->primary_type_id || 99) <=> ($b->medium->release->release_group->primary_type_id || 99)
        or
    ($a->medium->release->status_id || 99) <=> ($b->medium->release->status_id || 99)
        or
    ($a->medium->release->date->year || 9999) <=> ($b->medium->release->date->year || 9999)
        or
    ($a->medium->release->date->month || 12) <=> ($b->medium->release->date->month || 12)
        or
    ($a->medium->release->date->day || 31) <=> ($b->medium->release->date->day || 31)
}

sub lookup : Local
{
    my ($self, $c) = @_;

    my $toc = $c->req->query_params->{toc};
    $c->stash->{toc} = $toc;

    my $results = $c->model('DurationLookup')->lookup($toc, DURATION_LOOKUP_RANGE);
    if (defined $results)
    {
        $c->model('Release')->load(map { $_->medium } @{$results});
        if (scalar(@{$results}) == 1)
        {
             $c->response->redirect($c->uri_for("/release/" . $results->[0]->medium->release->gid));
        }
        else
        {
            $c->model('ReleaseGroup')->load(map { $_->medium->release } @{$results});
            $c->model('ReleaseGroupType')->load(map { $_->medium->release->release_group } @{$results});
            $c->model('ReleaseStatus')->load(map { $_->medium->release } @{$results});
            $c->model('MediumFormat')->load(map { $_->medium } @{$results});
            $c->model('ArtistCredit')->load(map { $_->medium->release } @{$results});
            my @sorted = sort medium_sort @{$results};
            $c->stash->{results} = \@sorted;
        }
    }
    else
    {
        $c->stash->{results} = [];
    }
}

=head2 duplicate

Duplicate a release into the add release editor

=cut

sub duplicate : Chained('load')
{
    my ($self, $c) = @_;
    $c->forward('/user/login');
    $c->forward('_load_related');
    $c->forward('/release_editor/duplicate_release');
}

sub _load_related : Private
{
    my ($self, $c) = @_;

    my $release = $self->entity;
    $c->stash->{artist}         = $c->model('Artist')->load($release->artist);
    $c->stash->{tracks}         = $c->model('Track')->load_from_release($release);
    $c->stash->{release_events} = $c->model('Release')->load_events($release, country_id => 1);
}

=head2 rating

Rate a release

=cut

sub rating : Chained('load') Args(2)
{
    my ($self, $c, $entity, $new_vote) = @_;
    #Need more validation here

    $c->forward('/user/login');
    $c->forward('/rating/do_rating', ['artist', $entity, $new_vote]);
    $c->response->redirect($c->entity_url($self->entity, 'show'));
}

sub change_quality : Chained('load') PathPart('change-quality') RequireAuth
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $self->edit_action(
        $c,
        item => $release,
        form => 'ChangeReleaseQuality',
        type => $EDIT_RELEASE_CHANGE_QUALITY,
        edit_args => { to_edit => $release },
        on_creation => sub {
            my $uri = $c->uri_for_action('/release/show', [ $release->gid ]);
            $c->response->redirect($uri);
        }
    );
}

=head2 collections

View a list of collections that this release has been added to.

=cut

sub collections : Chained('load') RequireAuth
{
    my ($self, $c) = @_;

    my @all_collections = $c->model('Collection')->find_all_by_release($c->stash->{release}->id);
    my @public_collections;
    my $private_collections = 0;

    # Keep public collections;
    # count private collection
    foreach my $collection (@all_collections) {
        push (@public_collections, $collection)
            if ($collection->{'public'} == 1);
        $private_collections++
            if ($collection->{'public'} == 0);
    }

    $c->model('Editor')->load(@public_collections);

    $c->stash(
        public_collections => \@public_collections,
        private_collections => $private_collections,
    );
}

sub cover_art_uploaded : Chained('load') PathPart('cover-art-uploaded')
{
    my ($self, $c) = @_;

    $c->stash->{filename} = $c->req->params->{key};
}

sub cover_art_uploader : Chained('load') PathPart('cover-art-uploader') RequireAuth
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $id = $c->req->query_params->{id} or die "Need destination ID";

    my $bucket = 'mbid-' . $entity->gid;
    my $redirect = $c->uri_for_action('/release/cover_art_uploaded',
                                      [ $entity->gid ],
                                      { id => $id })->as_string ();

    $c->stash->{form_action} = DBDefs->COVER_ART_ARCHIVE_UPLOAD_PREFIXER($bucket);
    $c->stash->{s3fields} = $c->model ('CoverArtArchive')->post_fields ($bucket, $entity->gid, $id, $redirect);
}

sub add_cover_art : Chained('load') PathPart('add-cover-art') RequireAuth
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{$self->{entity_name}};

    $c->model('Release')->load_meta($entity);

    if (!$entity->may_have_cover_art) {
        $c->stash( template => 'release/caa_darkened.tt' );
        $c->detach;
    }

    my @artwork = @{ $c->model ('CoverArtArchive')->find_available_artwork($entity->gid) };

    my $count = 1;
    my @positions = map {
        { id => $_->id, position => $count++ }
    } @artwork;

    my $id = $c->model('CoverArtArchive')->fresh_id;
    $c->stash({
        id => $id,
        index_url => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . "/release/" . $entity->gid . "/",
        images => \@artwork
    });

    my $form = $c->form(
        form => 'Release::AddCoverArt',
        item => {
            id => $id,
            position => $count
        }
    );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELEASE_ADD_COVER_ART,
                release => $entity,
                cover_art_types => [
                    grep { defined $_ && looks_like_number($_) }
                        @{ $form->field ("type_id")->value }
                    ],
                cover_art_position => $form->field ("position")->value,
                cover_art_id => $form->field('id')->value,
                cover_art_comment => $form->field('comment')->value || ''
            );
        });

        $c->response->redirect($c->uri_for_action('/release/cover_art', [ $entity->gid ]));
        $c->detach;
    }
}

sub reorder_cover_art : Chained('load') PathPart('reorder-cover-art') RequireAuth
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{$self->{entity_name}};

    $c->model('Release')->load_meta($entity);

    if (!$entity->may_have_cover_art) {
        $c->stash( template => 'release/caa_darkened.tt' );
        $c->detach;
    }

    my $artwork = $c->model ('Artwork')->find_by_release ($entity);
    $c->model ('CoverArtType')->load_for (@$artwork);

    $c->stash( images => $artwork );

    my $count = 1;
    my @positions = map {
        { id => $_->id, position => $count++ }
    } @$artwork;

    my $form = $c->form(
        form => 'Release::ReorderCoverArt',
        init_object => { artwork => \@positions }
    );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELEASE_REORDER_COVER_ART,
                release => $entity,
                old => \@positions,
                new => $form->field ("artwork")->value
            );
        });

        $c->response->redirect($c->uri_for_action('/release/cover_art', [ $entity->gid ]));
        $c->detach;
    };
}

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_RELEASE_MERGE,
    confirmation_template => 'release/merge_confirm.tt',
    search_template => 'release/merge_search.tt',
    merge_form => 'Merge::Release',
};

sub _merge_form_arguments {
    my ($self, $c, @releases) = @_;
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('Track')->load_for_mediums(map { $_->all_mediums } @releases);
    $c->model('Recording')->load(map { $_->all_tracks } map { $_->all_mediums } @releases);
    $c->model('ArtistCredit')->load(map { $_->all_tracks } map { $_->all_mediums } @releases);

    my @mediums;
    my %medium_by_id;
    foreach my $release (@releases) {
        foreach my $medium ($release->all_mediums) {
            my $position = $medium->position;
            my $name = $medium->name;
            if ($release->medium_count == 1 && !$name) {
                # guess position from the old release name
                if ($medium->release->name =~ /\(disc (\d+)(?:: (.+?))?\)/) {
                    $position = $1;
                    $name = $2 || '';
                }
            }
            push @mediums, {
                id => $medium->id,
                release_id => $medium->release_id,
                position => $position,
                name => $name
            };
            $medium_by_id{$medium->id} = $medium;
        }
    }

    my @bad_recording_merges;
    my @recording_merges = $c->model('Release')->determine_recording_merges(@releases);
    for my $recordings (@recording_merges) {
        my @ac_ids = map { $_->artist_credit_id } @$recordings;
        if (uniq(@ac_ids) > 1) {
            push @bad_recording_merges, $recordings;
        }
    }
    if (@bad_recording_merges) {
        $c->model('ArtistCredit')->load(map { @$_ } @bad_recording_merges);
    }

    @mediums = nsort_by { $_->{position} } @mediums;

    $c->stash(
        mediums => [ map { $medium_by_id{$_->{id}} } @mediums ],
        xxx_releases => \@releases,
        bad_recording_merges => \@bad_recording_merges,
    );

    return (
        init_object => { medium_positions => { map => \@mediums } }
    );
}

sub _merge_parameters {
    my ($self, $c, $form, $releases) = @_;
    if ($form->field('merge_strategy')->value == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
        my %release_map = map {
            $_->id => $_
        } @$releases;
        my %medium_changes;
        for my $merge ($form->field('medium_positions.map')->fields) {
            my $release = $release_map{ $merge->field('release_id')->value }
                or die 'Couldnt find release to link with';

            my ($medium) = grep { $_->id == $merge->field('id')->value }
                $release->all_mediums
                    or die 'Couldnt find medium';

            $medium_changes{ $release->id } ||= [];
            push @{ $medium_changes{ $release->id } },
                { id => $merge->field('id')->value,
                  old_position => $medium->position,
                  new_position => $merge->field('position')->value,
                  old_name => $medium->name,
                  new_name => $merge->field('name')->value };
        }
        return (
            medium_changes => [
                map +{
                    release => {
                        id => $_,
                        name => $release_map{$_}->name
                    },
                    mediums => $medium_changes{$_}
                }, keys %medium_changes
            ]
        )
    }
    else {
        return ();
    }
}

around _merge_submit => sub {
    my ($orig, $self, $c, $form, $entities) = @_;
    my $new_id = $form->field('target')->value or die 'Coludnt figure out new_id';
    my ($new, $old) = part { $_->id == $new_id ? 0 : 1 } @$entities;

    my $strat = $form->field('merge_strategy')->value;
    my %merge_opts = (
        merge_strategy => $strat,
        new_id => $new_id,
        old_ids => [ map { $_->id } @$old ],
    );

    # XXX Ripped from Edit/Release/Merge.pm need to find a better solution.
    if ($strat == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
        my %extra_params = $self->_merge_parameters($c, $form, $entities);
        $merge_opts{ medium_positions } = {
            map { $_->{id} => $_->{new_position} }
            map { @{ $_->{mediums} } }
                @{ $extra_params{medium_changes} }
        };
    }

    if ($c->model('Release')->can_merge(%merge_opts)) {
        $self->$orig($c, $form, $entities);
    }
    else {
        $form->field('merge_strategy')->add_error(
            l('This merge strategy is not applicable to the releases you have selected.')
        );
    }
};

after 'merge' => sub
{
    my ($self, $c) = @_;
    my @to_merge = @{ $c->stash->{to_merge} };
    load_release_events($c, @to_merge);
    $c->model('Medium')->load_for_releases(@to_merge);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @to_merge);
    $c->model('ReleaseLabel')->load(@to_merge);
    $c->model('Label')->load(map { $_->all_labels } @to_merge);
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_RELEASE_DELETE,
};

sub edit_cover_art : Chained('load') PathPart('edit-cover-art') Args(1) Edit RequireAuth
{
    my ($self, $c, $id) = @_;

    my $entity = $c->stash->{entity};

    my @artwork = @{
        $c->model ('CoverArtArchive')->find_available_artwork($entity->gid)
    } or $c->detach('/error_404');

    my $artwork = first { $_->id == $id } @artwork;

    $c->stash({
        artwork => $artwork,
        images => \@artwork,
        index_url => DBDefs->COVER_ART_ARCHIVE_DOWNLOAD_PREFIX . "/release/" . $entity->gid . "/"
    });

    my @type_ids = map { $_->id } $c->model ('CoverArtType')->get_by_name (@{ $artwork->types });

    my $form = $c->form(
        form => 'Release::EditCoverArt',
        item => {
            id => $id,
            type_id => \@type_ids,
            comment => $artwork->comment,
        }
    );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELEASE_EDIT_COVER_ART,
                release => $entity,
                artwork_id => $artwork->id,
                old_types => [ grep { defined $_ && looks_like_number($_) } @type_ids ],
                old_comment => $artwork->comment,
                new_types => [ grep { defined $_ && looks_like_number($_) } @{ $form->field ("type_id")->value } ],
                new_comment => $form->field('comment')->value || '',
            );
        });

        $c->response->redirect($c->uri_for_action('/release/cover_art', [ $entity->gid ]));
        $c->detach;
    }
}

sub remove_cover_art : Chained('load') PathPart('remove-cover-art') Args(1) Edit RequireAuth {
    my ($self, $c, $id) = @_;

    my $release = $c->stash->{entity};
    my $artwork = first { $_->id == $id }
        @{ $c->model ('CoverArtArchive')->find_available_artwork($release->gid) }
            or $c->detach('/error_404');

    $c->stash( artwork => $artwork );

    $self->edit_action($c,
        form        => 'Confirm',
        type        => $EDIT_RELEASE_REMOVE_COVER_ART,
        edit_args   => {
            release   => $release,
            to_delete => $artwork
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/release/cover_art', [ $release->gid ]));
        }
    )
}

sub cover_art : Chained('load') PathPart('cover-art') {
    my ($self, $c) = @_;
    my $release = $c->stash->{entity};
    $c->model('Release')->load_meta($release);

    my $artwork = $c->model ('Artwork')->find_by_release ($release);
    $c->model ('CoverArtType')->load_for (@$artwork);

    $c->stash(cover_art => $artwork);
}

sub edit_relationships : Chained('load') PathPart('edit-relationships') Edit RequireAuth {
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    $c->model('Release')->load_meta($release);
    $c->model('ArtistCredit')->load($release);
    $c->model('ReleaseGroup')->load($release);

    $c->forward('/relationship_editor/load', $c);
}

__PACKAGE__->meta->make_immutable;
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
