package MusicBrainz::Server::Controller::CDTOC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use List::AllUtils qw( first );
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Constants qw(
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_REMOVE_DISCID
    $EDIT_MEDIUM_MOVE_DISCID
    $EDIT_SET_TRACK_LENGTHS
    $EDITOR_MODBOT
    %ENTITIES
);
use MusicBrainz::Server::Entity::CDTOC;
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::ControllerUtils::CDTOC qw( add_dash );

use List::AllUtils qw( sort_by );

use HTTP::Status qw( :constants );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'CDTOC',
    entity_name => 'cdtoc'
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

    $c->stash(
        medium_cdtocs => $medium_cdtocs,
        template      => 'cdtoc/index.tt',
    );
}

sub remove : Local Edit
{
    my ($self, $c) = @_;
    my $cdtoc_id  = $c->req->query_params->{cdtoc_id};
    my $medium_id = $c->req->query_params->{medium_id};

    my $medium  = $c->model('Medium')->get_by_id($medium_id);
    my $release = $c->model('Release')->get_by_id($medium->release_id);
    $c->model('ArtistCredit')->load($release);
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);

    # For proper display of the Disc IDs tab
    $c->model('Medium')->load_for_releases($release);
    my $cdtoc_count = $c->model('MediumCDTOC')->find_count_by_release($release->id);
    $c->stash->{release_cdtoc_count} = $cdtoc_count;

    my $cdtoc = $c->model('MediumCDTOC')->get_by_medium_cdtoc($medium_id, $cdtoc_id);
    $c->model('CDTOC')->load($cdtoc);

    $c->stash(
        medium_cdtoc => $cdtoc,
        medium       => $medium,
        release      => $release,
        # These added so the entity tabs will appear properly
        entity       => $release,
        entity_properties => $ENTITIES{release}
    );

    $self->edit_action($c,
        form        => 'Confirm',
        form_args   => { requires_edit_note => 1 },
        type        => $EDIT_MEDIUM_REMOVE_DISCID,
        edit_args   => {
            medium => $medium,
            cdtoc  => $cdtoc
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/release/discids', [ $release->gid ]));
        }
    )
}

sub set_durations : Chained('load') PathPart('set-durations') Edit
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};
    my $medium_id = $c->req->query_params->{medium}
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Please provide a medium ID')
        );
    my $medium = $c->model('Medium')->get_by_id($medium_id)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('Could not find medium')
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
            cdtoc_id => $cdtoc->id
        },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action($self->action_for('show'), [ $cdtoc->discid ]));
        }
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
                'The provided CD TOC is not valid. This is probably an issue with the software you used to generate it. Try again and please report the error to your software maker if it persists, including the technical information below.')
        );

    $c->stash( cdtoc => $cdtoc );

    if (my $medium_id = $c->req->query_params->{medium}) {
        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium id is not valid')
            ) unless looks_like_number($medium_id);

        if ($c->model('MediumCDTOC')->medium_has_cdtoc($medium_id, $cdtoc)) {
            $c->stash->{medium_has_cdtoc} = $medium_id;
            $c->res->status(HTTP_BAD_REQUEST);
            $self->_attach_list($c, $cdtoc);
            return;
        }

        my $medium = $c->model('Medium')->get_by_id($medium_id);
        $c->model('MediumFormat')->load($medium);

        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs')
        ) unless $medium->may_have_discids;

        $c->model('Release')->load($medium);
        $c->model('Track')->load_for_mediums($medium);
        $c->model('Recording')->load($medium->all_tracks);
        $c->model('ArtistCredit')->load($medium->all_tracks, $medium->release);

        $c->stash( medium => $medium );

        $c->stash(template => 'cdtoc/attach_confirm.tt');
        $self->edit_action($c,
            form        => 'Confirm',
            type        => $EDIT_MEDIUM_ADD_DISCID,
            edit_args   => {
                cdtoc      => $toc,
                medium_id  => $medium_id,
                release    => $medium->release
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action(
                        '/release/discids' => [ $medium->release->gid ]));
            }
        );
    } else {
        $self->_attach_list($c, $cdtoc);
    }
}

sub _attach_list {
    my ($self, $c, $cdtoc) = @_;

    if (my $artist_id = $c->req->query_params->{artist}) {

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided artist id is not valid')
            ) unless looks_like_number($artist_id);

        # List releases
        my $artist = $c->model('Artist')->get_by_id($artist_id);
        my $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_for_cdtoc($artist_id, $cdtoc->track_count, shift, shift)
        });
        $c->model('Release')->load_related_info(@$releases);

        my @mediums = map { $_->all_mediums } @$releases;
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

        # One of these must have been submitted to get here
        if ($c->form_submitted_and_valid($search_artist, $c->req->query_params)) {
            my $artists = $self->_load_paged($c, sub {
                $c->model('Search')->search('artist', $search_artist->field('query')->value, shift, shift)
            });
            $c->stash(
                template => 'cdtoc/attach_filter_artist.tt',
                artists => $artists
            );
            $c->detach;
        }
        elsif ($c->form_submitted_and_valid($search_release, $c->req->query_params)) {
            my $query = $search_release->field('query')->value;
            my ($mbid) = $query =~ m/(
                [\da-f]{8} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{12}
            )/ax;
            my $releases = $self->_load_paged($c, sub {
                if (defined $mbid) {
                    $c->stash->{was_mbid_search} = 1;
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
            my @mediums = map { $_->all_mediums } @releases;
            $c->model('Track')->load_for_mediums(@mediums);

            my @tracks = map { $_->all_tracks } @mediums;
            $c->model('Recording')->load(@tracks);
            $c->model('ArtistCredit')->load(@releases, @tracks, map { $_->recording } @tracks);

            my @rgs = $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroup')->load_meta(@rgs);

            $c->stash(
                template => 'cdtoc/attach_filter_release.tt',
                cdtoc_action => 'add',
                results => [sort_by { $_->entity->release_group ? $_->entity->release_group->gid : '' } @$releases]
            );
            $c->detach;
        }
        else {
            my $cdstub = $c->model('CDStub')->get_by_discid($cdtoc->discid);
            if ($cdstub) {
                $c->model('CDStubTrack')->load_for_cdstub($cdstub);
                $cdstub->update_track_lengths;

                $initial_artist  ||= $cdstub->artist;
                $initial_release ||= $cdstub->title;

                my @mediums = $c->model('Medium')->find_for_cdstub($cdstub);
                $c->model('MediumFormat')->load(@mediums);
                $c->model('Track')->load_for_mediums(@mediums);
                my @tracks = map { $_->all_tracks } @mediums;
                $c->model('Recording')->load(@tracks);
                my @releases = map { $_->release } @mediums;
                $c->model('Release')->load_related_info(@releases);
                $c->model('ArtistCredit')->load(@releases);
                $c->stash(
                    possible_mediums => [ @mediums  ],
                    cdstub => $cdstub
                );
            }
        }

        $search_artist->process(params => { 'filter-artist.query' => $initial_artist })
            if $initial_artist;

        $search_release->process(params => { 'filter-release.query' => $initial_release })
            if $initial_release;

        $c->stash(
            medium_cdtocs => $self->_load_releases($c, $cdtoc),
            cdtoc => $cdtoc,
            template => 'cdtoc/lookup.tt',
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
            message => l('The provided CD TOC ID doesn’t exist.')
        );

    $c->model('CDTOC')->load($medium_cdtoc);
    my $cdtoc = $medium_cdtoc->cdtoc;

    $c->stash(
        cdtoc => $cdtoc,
        toc => $medium_cdtoc_id,
        medium_cdtoc => $medium_cdtoc
    );

    if (my $medium_id = $c->req->query_params->{medium}) {
        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium id is not valid')
            ) unless looks_like_number($medium_id);

        my $medium = $c->model('Medium')->get_by_id($medium_id);
        $c->model('MediumFormat')->load($medium);
        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs')
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

        $c->stash(
            medium => $medium
        );


        $c->stash(template => 'cdtoc/attach_confirm.tt');
        $self->edit_action($c,
            form        => 'Confirm',
            type        => $EDIT_MEDIUM_MOVE_DISCID,
            edit_args   => {
                medium_cdtoc => $medium_cdtoc,
                new_medium   => $medium
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action(
                        '/release/discids' => [ $medium->release->gid ]));
            }
        )
    }
    else {
        my $search_release = $c->form( query_release => 'Search::Query',
                                       name => 'filter-release' );
        $c->stash( template => 'cdtoc/move_search.tt' );

        if ($c->form_submitted_and_valid($search_release, $c->req->query_params)) {
            my $query = $search_release->field('query')->value;
            my ($mbid) = $query =~ m/(
                [\da-f]{8} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{4} -
                [\da-f]{12}
            )/ax;

            my $releases = $self->_load_paged($c, sub {
                if (defined $mbid) {
                    $c->stash->{was_mbid_search} = 1;
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
            $c->stash(
                template => 'cdtoc/attach_filter_release.tt',
                cdtoc_action => 'move',
                results => $releases
            );
            $c->detach;
        }
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
