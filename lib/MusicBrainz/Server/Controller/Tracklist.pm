package MusicBrainz::Server::Controller::Tracklist;
use Moose;

use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use Scalar::Util qw( looks_like_number );

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub tracklist : Chained('/') PathPart('tracklist') CaptureArgs(1)
{
    my ($self, $c, $id) = @_;

    $c->detach('/error_404') unless looks_like_number($id);

    my $tracklist = $c->model('Tracklist')->get_by_id($id)
        or $c->detach('/error_404');

    $c->stash( tracklist => $tracklist );
}

sub show : Chained('tracklist') PathPart('')
{
    my ($self, $c) = @_;

    my $tracklist = $c->stash->{tracklist};
    $c->model('Track')->load_for_tracklists($tracklist);
    my @recordings = $c->model('Recording')->load($tracklist->all_tracks);
    $c->model('Recording')->load_meta(@recordings);
    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @recordings);
    }

    my $release_media = $self->_load_paged($c, sub {
            $c->model('Medium')->find_by_tracklist($tracklist->id, shift, shift);
        });

    my @releases = map { $_->release } @$release_media;
    $c->model('ArtistCredit')->load(
        $tracklist->all_tracks, @releases);
    load_release_events($c, @releases);
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);

    $c->stash(
        show_artists => 1,
        release_media => $release_media,
        template => 'tracklist/index.tt'
    );
}

1;

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

