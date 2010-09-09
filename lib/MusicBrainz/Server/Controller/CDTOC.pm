package MusicBrainz::Server::Controller::CDTOC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_REMOVE_DISCID
);
use MusicBrainz::Server::Entity::CDTOC;

__PACKAGE__->config( entity_name => 'cdtoc' );

sub base : Chained('/') PathPart('cdtoc') CaptureArgs(0) {}

sub _load
{
    my ($self, $c, $discid) = @_;

    return $c->model('CDTOC')->get_by_discid($discid);
}

sub _load_releases
{
    my ($self, $c, $cdtoc) = @_;
    my @medium_cdtocs = $c->model('MediumCDTOC')->find_by_cdtoc($cdtoc->id);
    my @mediums = $c->model('Medium')->load(@medium_cdtocs);
    my @releases = $c->model('Release')->load(@mediums);
    $c->model('MediumFormat')->load(@mediums);
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('Country')->load(@releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->model('ArtistCredit')->load(@releases);
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
            cdtoc_id     => $cdtoc_id,
            medium_id    => $medium_id,
            medium_cdtoc => $cdtoc->id
        },
        on_creation => sub {
            $c->response->redirect($c->uri_for_action('/release/discids', [ $release->gid ]));
            $c->detach;
        }
    )
}

sub lookup : Local
{
    my ($self, $c) = @_;

    my $discid = $c->req->query_params->{id};
    my $track_count = $c->req->query_params->{tracks};
    my $toc = $c->req->query_params->{toc};

    my $cdtoc = $c->model('CDTOC')->get_by_discid($discid);
    if ($cdtoc) {
        $c->stash( medium_cdtocs => $self->_load_releases($c, $cdtoc) );
    }

    $c->form( query_release => 'Search::Query', name => 'filter-release' );
    $c->form( query_artist => 'Search::Query', name => 'filter-artist' );
}

sub attach : Local RequireAuth
{
    my ($self, $c) = @_;

    my $toc = $c->req->query_params->{toc};
    $c->stash( toc => $toc );
    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($toc);
        # FIXME or BAD REQUEST

    $c->stash( cdtoc => $cdtoc );

    if (my $release_id = $c->req->query_params->{release}) {
        my $release = $c->model('Release')->get_by_id($release_id); # FIXME or 404
        $c->model('ArtistCredit')->load($release);
        $c->stash( release => $release );

        # Load the release, list mediums
        $c->model('Medium')->load_for_releases($release);
        $c->model('Tracklist')->load($release->all_mediums);
        my @possible_mediums = grep { $_->tracklist->track_count == $cdtoc->track_count } $release->all_mediums;

        my $medium_id = $c->req->query_params->{medium};
        $medium_id = $possible_mediums[0]->id if @possible_mediums == 1 && !defined $medium_id;

        # FIXME $medium_id IN @possible_mediums or bad request

        if ($medium_id) {
            $c->stash(template => 'cdtoc/attach_confirm.tt');
            $self->edit_action($c,
                form        => 'Confirm',
                type        => $EDIT_MEDIUM_ADD_DISCID,
                edit_args   => {
                    cdtoc      => $toc,
                    medium_id  => $medium_id,
                    release_id => $release_id
                },
                on_creation => sub {
                    $c->response->redirect($c->uri_for_action('/release/discids', [ $release->gid ]));
                    $c->detach;
                }
            )
        }
        else {
            $c->stash(
                mediums => \@possible_mediums,
                template => 'cdtoc/attach_medium.tt'
            );
        }
    }
    elsif (my $artist_id = $c->req->query_params->{artist_id}) {
        # List releases
        $c->stash(template => 'cdtoc/attach_artist_releases.tt');
    }
    else {
        my $search_artist = $c->form( query_release => 'Search::Query', name => 'filter-release' );
        my $search_release = $c->form( query_artist => 'Search::Query', name => 'filter-artist' );

        # One of these must have been submitted to get here
        if ($search_artist->submitted_and_valid($c->req->query_params)) {
            $c->stash(template => 'cdtoc/attach_filter_artist.tt');
        }
        elsif ($search_release->submitted_and_valid($c->req->query_params)) {
            $c->stash(template => 'cdtoc/attach_filter_release.tt');
        }
        else {
            $c->stash( template => 'cdtoc/lookup.tt' );
            $c->forward('/cdtoc/lookup');
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
