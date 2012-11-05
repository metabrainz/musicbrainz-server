package MusicBrainz::Server::Controller::CDTOC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use List::Util qw( first );
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Constants qw(
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_REMOVE_DISCID
    $EDIT_MEDIUM_MOVE_DISCID
    $EDIT_SET_TRACK_LENGTHS
    $EDITOR_MODBOT
);
use MusicBrainz::Server::Entity::CDTOC;
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::ControllerUtils::CDTOC qw( add_dash );

use List::UtilsBy qw( sort_by );

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
    my @releases = $c->model('Release')->load(@mediums);
    $c->model('MediumFormat')->load(@mediums);
    $c->model('Medium')->load_for_releases(@releases);
    my @rgs = $c->model('ReleaseGroup')->load(@releases);
    $c->model('ReleaseGroup')->load_meta(@rgs);
    $c->model('Country')->load(@releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->model('ArtistCredit')->load(@releases);
    $c->model('CDTOC')->load(@medium_cdtocs);
    return \@medium_cdtocs;
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};

    $c->stash(
        medium_cdtocs => $self->_load_releases($c, $cdtoc),
        template      => 'cdtoc/index.tt',
    );
}

sub remove : Local RequireAuth
{
    my ($self, $c) = @_;
    my $cdtoc_id  = $c->req->query_params->{cdtoc_id};
    my $medium_id = $c->req->query_params->{medium_id};

    my $medium  = $c->model('Medium')->get_by_id($medium_id);
    my $release = $c->model('Release')->get_by_id($medium->release_id);
    $c->model('ArtistCredit')->load($release);
    $c->model('ReleaseGroup')->load($release);

    my $cdtoc = $c->model('MediumCDTOC')->get_by_medium_cdtoc($medium_id, $cdtoc_id);
    $c->model('CDTOC')->load($cdtoc);

    $c->stash(
        medium_cdtoc => $cdtoc,
        medium       => $medium,
        release      => $release
    );

    $self->edit_action($c,
        form        => 'Confirm',
        type        => $EDIT_MEDIUM_REMOVE_DISCID,
        edit_args   => {
            medium => $medium,
            cdtoc  => $cdtoc
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/release/discids', [ $release->gid ]));
            $c->detach;
        }
    )
}

sub set_durations : Chained('load') PathPart('set-durations') Edit RequireAuth
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};
    my $tracklist_id = $c->req->query_params->{tracklist};
    my ($mediums) = $c->model('Medium')->find_by_tracklist(
        $tracklist_id, 100, 0)
        or die "Could not find mediums";

    $c->model('Release')->load(@$mediums);

    $c->model('Track')->load_for_tracklists(
        $c->model('Tracklist')->load($mediums->[0]));
    $c->model('Recording')->load($mediums->[0]->tracklist->all_tracks);

    $c->model('ArtistCredit')->load($mediums->[0]->tracklist->all_tracks, map { $_->release } @$mediums);

    $c->stash( mediums => $mediums );

    $self->edit_action($c,
        form => 'Confirm',
        type => $EDIT_SET_TRACK_LENGTHS,
        edit_args => {
            tracklist_id => $tracklist_id,
            cdtoc_id => $cdtoc->id
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action($self->action_for('show'), [ $cdtoc->discid ]));
            $c->detach;
        }
    );
}

sub attach : Local
{
    my ($self, $c) = @_;

    my $toc = $c->req->query_params->{toc};
    $c->stash( toc => $toc );
    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($toc)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('The provided CD TOC is not valid')
        );

    $c->stash( cdtoc => $cdtoc );

    if ($c->form_posted) {
        $c->forward('/user/do_login');
    }

    if (my $medium_id = $c->req->query_params->{medium}) {
        $c->forward('/user/do_login');

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided medium id is not valid')
            ) unless looks_like_number ($medium_id);

        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('This CDTOC is already attached to this medium')
        ) if $c->model('MediumCDTOC')->medium_has_cdtoc($medium_id, $cdtoc);

        my $medium = $c->model('Medium')->get_by_id($medium_id);
        $c->model('MediumFormat')->load($medium);

        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs')
        ) unless $medium->may_have_discids;

        $c->model('Release')->load($medium);
        $c->model('ArtistCredit')->load($medium->release);

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
                $c->detach;
            }
        )
    }
    elsif (my $artist_id = $c->req->query_params->{artist}) {

        $self->error($c, status => HTTP_BAD_REQUEST,
                     message => l('The provided artist id is not valid')
            ) unless looks_like_number ($artist_id);

        # List releases
        my $artist = $c->model('Artist')->get_by_id($artist_id);
        my $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_for_cdtoc($artist_id, $cdtoc->track_count,shift, shift)
        });
        $c->model('Medium')->load_for_releases(@$releases);
        $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
        $c->model('Track')->load_for_tracklists(
            map { $_->tracklist } map { $_->all_mediums } @$releases);
        $c->model('Country')->load(@$releases);
        $c->model('ReleaseLabel')->load(@$releases);
        $c->model('Label')->load(map { $_->all_labels } @$releases);
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
        if ($search_artist->submitted_and_valid($c->req->query_params)) {
            my $artists = $self->_load_paged($c, sub {
                $c->model('Search')->search('artist', $search_artist->field('query')->value, shift, shift)
            });
            $c->stash(
                template => 'cdtoc/attach_filter_artist.tt',
                artists => $artists
            );
            $c->detach;
        }
        elsif ($search_release->submitted_and_valid($c->req->query_params)) {
            my $releases = $self->_load_paged($c, sub {
                $c->model('Search')->search('release', $search_release->field('query')->value, shift, shift,
                                            { track_count => $cdtoc->track_count });
            });
            my @releases = map { $_->entity } @$releases;
            $c->model('Medium')->load_for_releases(@releases);
            $c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
            my @mediums = map { $_->all_mediums } @releases;
            $c->model('Track')->load_for_tracklists( map { $_->tracklist } @mediums);

            my @tracks = map { $_->all_tracks } map { $_->tracklist } @mediums;
            $c->model('Recording')->load(@tracks);
            $c->model('ArtistCredit')->load(@releases, @tracks, map { $_->recording } @tracks);
            $c->model('Country')->load(@releases);
            $c->model('ReleaseLabel')->load(@releases);
            $c->model('Label')->load(map { $_->all_labels } @releases);

            my @rgs = $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroup')->load_meta(@rgs);

            $c->stash(
                template => 'cdtoc/attach_filter_release.tt',
                results => [sort_by { $_->entity->release_group ? $_->entity->release_group->gid : '' } @$releases]
            );
            $c->detach;
        }
        else {
            my $stub_toc = $c->model('CDStubTOC')->get_by_discid($cdtoc->discid);
            if($stub_toc) {
                $c->model('CDStub')->load($stub_toc);
                $c->model('CDStubTrack')->load_for_cdstub($stub_toc->cdstub);
                $stub_toc->update_track_lengths;

                $initial_artist  ||= $stub_toc->cdstub->artist;
                $initial_release ||= $stub_toc->cdstub->title;

                my @mediums = $c->model('Medium')->find_for_cdstub($stub_toc);
                $c->model('ArtistCredit')->load(map { $_->release } @mediums);
                $c->stash(
                    possible_mediums => [ @mediums  ],
                    cdstubtoc => $stub_toc
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

sub move : Local RequireAuth Edit
{
    my ($self, $c) = @_;

    my $medium_cdtoc_id = $c->req->query_params->{toc};
    my $medium_cdtoc = $c->model('MediumCDTOC')->get_by_id($medium_cdtoc_id)
        or $self->error(
            $c, status => HTTP_BAD_REQUEST,
            message => l('The provided CD TOC is not valid')
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
            ) unless looks_like_number ($medium_id);

        my $medium = $c->model('Medium')->get_by_id($medium_id);
        $c->model('MediumFormat')->load($medium);
        $self->error(
            $c,
            status => HTTP_BAD_REQUEST,
            message => l('The selected medium cannot have disc IDs')
        ) unless $medium->may_have_discids;

        $c->model('Medium')->load($medium_cdtoc);

        $c->model('Release')->load($medium, $medium_cdtoc->medium);
        $c->model('Country')->load($medium->release);
        $c->model('ReleaseLabel')->load($medium->release);
        $c->model('Label')->load($medium->release->all_labels);
        $c->model('ArtistCredit')->load($medium->release, $medium_cdtoc->medium->release);

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
                $c->detach;
            }
        )
    }
    else {
        my $search_release = $c->form( query_release => 'Search::Query',
                                       name => 'filter-release' );
        $c->stash( template => 'cdtoc/move_search.tt' );

        if ($search_release->submitted_and_valid($c->req->query_params)) {
            my $releases = $self->_load_paged($c, sub {
                $c->model('Search')->search('release', $search_release->field('query')->value, shift, shift,
                                            { track_count => $cdtoc->track_count });
            });
            my @releases = map { $_->entity } @$releases;
            $c->model('ArtistCredit')->load(@releases);
            $c->model('Medium')->load_for_releases(@releases);
            $c->model('Country')->load(@releases);
            $c->model('ReleaseLabel')->load(@releases);
            $c->model('Label')->load(map { $_->all_labels } @releases);
            $c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
            my @mediums = grep { !$_->format || $_->format->has_discids }
                map { $_->all_mediums } @releases;
            $c->model('Track')->load_for_tracklists( map { $_->tracklist } @mediums);
            $c->stash(
                template => 'cdtoc/attach_filter_release.tt',
                results => $releases
            );
            $c->detach;
        }
    }
}

no Moose;
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
