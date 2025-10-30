package MusicBrainz::Server::Controller::CDTOC;
use Moose;
use MooseX::MethodAttributes;

extends 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Constants qw(
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_REMOVE_DISCID
    $EDIT_MEDIUM_MOVE_DISCID
    $EDIT_SET_TRACK_LENGTHS
);
use MusicBrainz::Server::Entity::CDTOC;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::ControllerUtils::CDTOC qw( add_dash );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Validation qw(
    is_database_row_id
);
use List::AllUtils qw( sort_by );

use HTTP::Status qw( :constants );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'CDTOC',
    entity_name => 'cdtoc',
};

sub base : Chained('/') PathPart('cdtoc') CaptureArgs(0) {}

sub _load
{
    my ($self, $c, $discid) = @_;

    add_dash($c, $discid);

    return $c->model('CDTOC')->get_by_discid($discid);
}

sub _load_releases
{
    my ($self, $c, $cdtoc) = @_;
    my @medium_cdtocs = $c->model('MediumCDTOC')->find_by_discid($cdtoc->discid);
    my @mediums = $c->model('Medium')->load(@medium_cdtocs);
    $c->model('Medium')->load_track_durations(@mediums);
    $c->model('Track')->load_for_mediums(@mediums);
    my @tracks = map { $_->all_tracks } @mediums;
    $c->model('Recording')->load(@tracks);
    my @releases = $c->model('Release')->load(@mediums);
    my @rgs = $c->model('ReleaseGroup')->load(@releases);
    $c->model('ReleaseGroup')->load_meta(@rgs);
    $c->model('Release')->load_related_info(@releases);
    $c->model('ArtistCredit')->load(@releases);
    $c->model('MediumFormat')->load(@mediums);
    $c->model('CDTOC')->load(@medium_cdtocs);
    return \@medium_cdtocs;
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};
    my $medium_cdtocs = $self->_load_releases($c, $cdtoc);

    my %props = (
        mediumCDTocs => to_json_array($medium_cdtocs),
        cdToc        => $cdtoc->TO_JSON,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'cdtoc/CDTocIndex.js',
        component_props => \%props,
    );
}

sub remove : Local Edit
{
    my ($self, $c) = @_;
    my $cdtoc_id  = $c->req->query_params->{cdtoc_id}
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Please provide a CD TOC ID.'),
        );

    $self->error($c, status => HTTP_BAD_REQUEST,
                 message => l('The provided CD TOC ID is not valid.'),
        ) unless is_database_row_id($cdtoc_id);

    my $medium_id = $c->req->query_params->{medium_id}
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Please provide a medium ID.'),
        );

    $self->error($c, status => HTTP_BAD_REQUEST,
                 message => l('The provided medium ID is not valid.'),
        ) unless is_database_row_id($medium_id);

    my $medium = $c->model('Medium')->get_by_id($medium_id)
            or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('The provided medium ID doesn’t exist.'),
        );

    my $cdtoc = $c->model('MediumCDTOC')->get_by_medium_cdtoc($medium_id, $cdtoc_id)
            or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('The provided CD TOC ID doesn’t exist or is not connected to the provided medium.'),
        );

    $c->model('CDTOC')->load($cdtoc);

    my $release = $c->model('Release')->get_by_id($medium->release_id);
    $c->model('ArtistCredit')->load($release);
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);

    # For proper display of the Disc IDs tab
    $c->model('Medium')->load_for_releases($release);
    my $cdtoc_count = $c->model('MediumCDTOC')->find_count_by_release($release->id);
    $c->stash->{release_cdtoc_count} = $cdtoc_count;

    $self->edit_action($c,
        form        => 'Confirm',
        form_args   => { requires_edit_note => 1 },
        type        => $EDIT_MEDIUM_REMOVE_DISCID,
        edit_args   => {
            medium => $medium,
            cdtoc  => $cdtoc,
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/release/discids', [ $release->gid ]));
        },
    );

    my %props = (
        mediumCDToc => $cdtoc->TO_JSON,
        form        => $c->stash->{form}->TO_JSON,
        release     => $release->TO_JSON,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'cdtoc/RemoveDiscId.js',
        component_props => \%props,
    );
}

sub set_durations : Chained('load') PathPart('set-durations') Edit
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};
    my $medium_id = $c->req->query_params->{medium}
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Please provide a medium ID.'),
        );
    my $medium = $c->model('Medium')->get_by_id($medium_id)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Could not find medium'),
        );

    $c->model('Medium')->load_track_durations($medium);
    $c->model('Release')->load($medium);

    $c->model('Track')->load_for_mediums($medium);
    $c->model('Recording')->load($medium->all_tracks);
    $c->model('ArtistCredit')->load($medium->all_tracks, $medium->release);

    $c->stash( medium => $medium );

    $self->edit_action($c,
        form => 'Confirm',
        type => $EDIT_SET_TRACK_LENGTHS,
        edit_args => {
            medium_id => $medium_id,
            cdtoc_id => $cdtoc->id,
        },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action($self->action_for('show'), [ $cdtoc->discid ]));
        },
    );

    my %props = (
        cdToc   => $cdtoc->TO_JSON,
        form    => $c->stash->{form}->TO_JSON,
        medium  => $medium->TO_JSON,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'cdtoc/SetTracklistDurations.js',
        component_props => \%props,
    );
}

sub attach : Local DenyWhenReadonly Edit
{
    my ($self, $c) = @_;

    my $toc = $c->req->query_params->{toc};
    $c->stash( toc => $toc );
    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($toc)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l(
                'The provided CD TOC is not valid. This is probably an issue with the software you used to generate it. Try again and please report the error to your software maker if it persists, including the technical information below.'),
        );

    $c->stash( cdtoc => $cdtoc );

    if (my $medium_id = $c->req->query_params->{medium}) {
        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium ID is not valid.'),
            ) unless is_database_row_id($medium_id);

        if ($c->model('MediumCDTOC')->medium_has_cdtoc($medium_id, $cdtoc)) {
            $c->stash->{medium_has_cdtoc} = $medium_id;
            $c->res->status(HTTP_BAD_REQUEST);
            $self->_attach_list($c, $cdtoc);
            return;
        }

        my $medium = $c->model('Medium')->get_by_id($medium_id);

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium ID doesn’t exist.'),
            ) unless defined $medium;

        $c->model('MediumFormat')->load($medium);

        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs'),
        ) unless $medium->may_have_discids;

        $c->model('Release')->load($medium);
        $c->model('Track')->load_for_mediums($medium);
        $c->model('Recording')->load($medium->all_tracks);
        $c->model('ArtistCredit')->load($medium->all_tracks, $medium->release);

        $self->edit_action($c,
            form        => 'Confirm',
            type        => $EDIT_MEDIUM_ADD_DISCID,
            edit_args   => {
                cdtoc      => $toc,
                medium_id  => $medium_id,
                release    => $medium->release,
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action(
                        '/release/discids' => [ $medium->release->gid ]));
            },
        );

        my %props = (
            cdToc   => $cdtoc->TO_JSON,
            form    => $c->stash->{form}->TO_JSON,
            medium  => $medium->TO_JSON,
        );

        $c->stash(
            current_view => 'Node',
            component_path => 'cdtoc/AttachCDTocConfirmation.js',
            component_props => \%props,
        );
    } else {
        $self->_attach_list($c, $cdtoc);
    }
}

sub _attach_list {
    my ($self, $c, $cdtoc) = @_;

    if (my $artist_id = $c->req->query_params->{artist}) {

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided artist id is not valid'),
            ) unless is_database_row_id($artist_id);

        # List releases
        my $artist = $c->model('Artist')->get_by_id($artist_id);
        my $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_for_cdtoc($artist_id, $cdtoc->track_count, shift, shift);
        });
        $c->model('Release')->load_related_info(@$releases);

        my @mediums = grep { !$_->format || $_->format->has_discids }
            map { $_->all_mediums } @$releases;
        $c->model('Track')->load_for_mediums(@mediums);

        my @tracks = map { $_->all_tracks } @mediums;
        $c->model('Recording')->load(@tracks);

        my @rgs = $c->model('ReleaseGroup')->load(@$releases);
        $c->model('ReleaseGroup')->load_meta(@rgs);

        $c->stash(
            artist => $artist,
            releases => $releases,
            template => 'cdtoc/attach_artist_releases.tt',
        );
    }
    else {
        my $search_artist = $c->form( query_artist => 'Search::Query', name => 'filter-artist' );
        my $search_release = $c->form( query_release => 'Search::Query', name => 'filter-release' );

        my ($initial_artist, $initial_release) = map { $c->req->query_params->{$_} }
            qw( artist-name release-name );

        my $cdstub;
        my @possible_mediums;
        # One of these must have been submitted to get here
        if ($c->form_submitted_and_valid($search_artist, $c->req->query_params)) {
            my $artists = $self->_load_paged($c, sub {
                $c->model('Search')->search('artist', $search_artist->field('query')->value, shift, shift);
            });
            my %props = (
                form        => $search_artist->TO_JSON,
                cdToc       => $cdtoc->TO_JSON,
                pager       => serialize_pager($c->stash->{pager}),
                results     => to_json_array($artists),
                tocString   => $c->stash->{toc},
            );
            $c->stash(
                current_view => 'Node',
                component_path => 'cdtoc/SelectArtistForCDToc.js',
                component_props => \%props,
            );
            $c->detach;
        }
        elsif ($c->form_submitted_and_valid($search_release, $c->req->query_params)) {
            my $query = $search_release->field('query')->value;
            my $was_mbid_search = 0;
            my ($mbid) = $query =~ m/(
                [\da-f]{8} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{12}
            )/ax;
            my $releases = $self->_load_paged($c, sub {
                if (defined $mbid) {
                    $was_mbid_search = 1;
                    my $release = $c->model('Release')->get_by_gid($mbid);
                    return [] unless defined $release;
                    return [
                        MusicBrainz::Server::Entity::SearchResult->new(
                            position => 1,
                            score => 100,
                            entity => $release,
                        ),
                    ];
                }
                $c->model('Search')->search('release', $query, shift, shift,
                                            { track_count => $cdtoc->track_count });
            });

            my @releases = map { $_->entity } @$releases;
            $c->model('Release')->load_related_info(@releases);
            my @mediums = grep { !$_->format || $_->format->has_discids }
                map { $_->all_mediums } @releases;
            $c->model('Track')->load_for_mediums(@mediums);

            my @tracks = map { $_->all_tracks } @mediums;
            $c->model('Recording')->load(@tracks);
            $c->model('ArtistCredit')->load(@releases, @tracks, map { $_->recording } @tracks);

            my @rgs = $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroup')->load_meta(@rgs);

            my $sorted_releases = [sort_by {
                $_->entity->release_group
                    ? $_->entity->release_group->gid
                    : ''
            } @$releases];

            my $medium_has_cdtoc = $c->stash->{medium_has_cdtoc};
            my %props = (
                action      => 'add',
                form        => $search_release->TO_JSON,
                cdToc       => $cdtoc->TO_JSON,
                pager       => serialize_pager($c->stash->{pager}),
                results     => to_json_array($sorted_releases),
                tocString   => $c->stash->{toc},
                wasMbidSearch => boolean_to_json($was_mbid_search),
                associatedMedium => defined $medium_has_cdtoc ? (0 + $medium_has_cdtoc) : undef,
            );

            $c->stash(
                current_view => 'Node',
                component_path => 'cdtoc/AttachCDTocToRelease.js',
                component_props => \%props,
            );
            $c->detach;
        }
        else {
            $cdstub = $c->model('CDStub')->get_by_discid($cdtoc->discid);
            if ($cdstub) {
                $c->model('CDStubTrack')->load_for_cdstub($cdstub);
                $cdstub->update_track_lengths;

                $initial_artist  ||= $cdstub->artist;
                $initial_release ||= $cdstub->title;

                @possible_mediums = $c->model('Medium')->find_for_cdstub($cdstub);
                $c->model('MediumFormat')->load(@possible_mediums);
                $c->model('Track')->load_for_mediums(@possible_mediums);
                my @tracks = map { $_->all_tracks } @possible_mediums;
                $c->model('Recording')->load(@tracks);
                my @releases = map { $_->release } @possible_mediums;
                $c->model('Release')->load_related_info(@releases);
                $c->model('ArtistCredit')->load(@releases);
                $c->stash(
                    possible_mediums => [ @possible_mediums ],
                    cdstub => $cdstub,
                );
            }
        }

        $search_artist->process(params => { 'filter-artist.query' => $initial_artist })
            if $initial_artist;

        $search_release->process(params => { 'filter-release.query' => $initial_release })
            if $initial_release;

        my $medium_cdtocs = $self->_load_releases($c, $cdtoc);

        my %props = (
            $cdstub ? (cdStub => $cdstub->TO_JSON) : (),
            cdToc => $cdtoc->TO_JSON,
            mediumCDTocs => to_json_array($medium_cdtocs),
            possibleMediums => to_json_array(\@possible_mediums),
            searchArtistForm => $search_artist->TO_JSON,
            searchReleaseForm => $search_release->TO_JSON,
            tocString => $c->stash->{toc},
        );

        $c->stash(
            current_view => 'Node',
            component_path => 'cdtoc/CDTocLookup.js',
            component_props => \%props,
        );
    }
}

sub move : Local Edit
{
    my ($self, $c) = @_;

    my $medium_cdtoc_id = $c->req->query_params->{toc};
    my $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id($medium_cdtoc_id)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('The provided CD TOC ID doesn’t exist.'),
        );

    $c->model('CDTOC')->load($medium_cdtoc);
    my $cdtoc = $medium_cdtoc->cdtoc;

    $c->stash(
        cdtoc => $cdtoc,
        toc => $medium_cdtoc_id,
        medium_cdtoc => $medium_cdtoc,
    );

    if (my $medium_id = $c->req->query_params->{medium}) {
        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium ID is not valid.'),
            ) unless is_database_row_id($medium_id);

        my $medium = $c->model('Medium')->get_by_id($medium_id);

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium ID doesn’t exist.'),
            ) unless defined $medium;

        $c->model('MediumFormat')->load($medium);
        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs'),
        ) unless $medium->may_have_discids;

        $c->model('Medium')->load($medium_cdtoc);
        $c->model('Medium')->load_track_durations($medium_cdtoc->medium);

        $c->model('Track')->load_for_mediums($medium);
        $c->model('Recording')->load($medium->all_tracks);
        $c->model('Release')->load($medium, $medium_cdtoc->medium);
        $c->model('Release')->load_release_events($medium->release);
        $c->model('ReleaseLabel')->load($medium->release);
        $c->model('Label')->load($medium->release->all_labels);
        $c->model('ArtistCredit')->load($medium->all_tracks, $medium->release, $medium_cdtoc->medium->release);

        $self->edit_action($c,
            form        => 'Confirm',
            type        => $EDIT_MEDIUM_MOVE_DISCID,
            edit_args   => {
                medium_cdtoc => $medium_cdtoc,
                new_medium   => $medium,
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action(
                        '/release/discids' => [ $medium->release->gid ]));
            },
        );

        my %props = (
            cdToc   => $cdtoc->TO_JSON,
            form    => $c->stash->{form}->TO_JSON,
            medium  => $medium->TO_JSON,
        );

        $c->stash(
            current_view => 'Node',
            component_path => 'cdtoc/AttachCDTocConfirmation.js',
            component_props => \%props,
        );
    }
    else {
        my $search_release = $c->form( query_release => 'Search::Query',
                                       name => 'filter-release' );

        my %props;

        if ($c->form_submitted_and_valid($search_release, $c->req->query_params)) {
            my $query = $search_release->field('query')->value;
            my $was_mbid_search = 0;
            my ($mbid) = $query =~ m/(
                [\da-f]{8} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{12}
            )/ax;

            my $releases = $self->_load_paged($c, sub {
                if (defined $mbid) {
                    $was_mbid_search = 1;
                    my $release = $c->model('Release')->get_by_gid($mbid);
                    return [] unless defined $release;
                    return [
                        MusicBrainz::Server::Entity::SearchResult->new(
                            position => 1,
                            score => 100,
                            entity => $release,
                        ),
                    ];
                }
                $c->model('Search')->search('release', $query, shift, shift,
                                            { track_count => $cdtoc->track_count });
            });

            my @releases = map { $_->entity } @$releases;
            $c->model('ArtistCredit')->load(@releases);
            $c->model('Release')->load_related_info(@releases);
            my @mediums = grep { !$_->format || $_->format->has_discids }
                map { $_->all_mediums } @releases;
            $c->model('Track')->load_for_mediums(@mediums);
            $c->model('Recording')->load(map { $_->all_tracks } @mediums);
            my @rgs = $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroup')->load_meta(@rgs);

            %props = (
                action      => 'move',
                cdToc       => $cdtoc->TO_JSON,
                form        => $search_release->TO_JSON,
                pager       => serialize_pager($c->stash->{pager}),
                results     => to_json_array($releases),
                tocString   => $medium_cdtoc->id,
                wasMbidSearch => boolean_to_json($was_mbid_search),
            );
        } else {
            %props = (
                action      => 'move',
                cdToc       => $cdtoc->TO_JSON,
                form        => $search_release->TO_JSON,
                tocString   => $medium_cdtoc->id,
            );
        }

        $c->stash(
            current_view => 'Node',
            component_path => 'cdtoc/AttachCDTocToRelease.js',
            component_props => \%props,
        );
    }
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
