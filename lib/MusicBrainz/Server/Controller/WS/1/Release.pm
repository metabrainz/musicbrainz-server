package MusicBrainz::Server::Controller::WS::1::Release;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller::WS::1' }

__PACKAGE__->config(
    model => 'Release',
);

my $ws_defs = Data::OptList::mkopt([
    release => {
        method => 'GET',
        inc    => [ qw( artist  tags  release-groups tracks release-events labels isrcs
                        ratings puids _relations     counts discs ) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

with 'MusicBrainz::Server::Controller::WS::1::Role::ArtistCredit';
with 'MusicBrainz::Server::Controller::WS::1::Role::Relationships';

sub root : Chained('/') PathPart('ws/1/release') CaptureArgs(0) { }

sub lookup : Chained('load') PathPart('')
{
    my ($self, $c, $gid) = @_;

    my $release = $c->stash->{entity};

    # This is always displayed, regardless of inc parameters
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('ReleaseStatus')->load($release);
    $c->model('Language')->load($release);
    $c->model('Script')->load($release);
    $c->model('Relationship')->load_subset([ 'url' ], $release);

    if ($c->stash->{inc}->tags) {
        my ($tags, $hits) = $c->model('ReleaseGroup')->tags->find_tags($release->release_group->id);
        $c->stash->{data}{tags} = $tags;
    }

    if ($c->stash->{inc}->tracks) {
        $c->model('Medium')->load_for_releases($release);

        my @mediums = $release->all_mediums;
        my @tracklists = grep { defined } map { $_->tracklist } @mediums;
        $c->model('Track')->load_for_tracklists(@tracklists);
        $c->model('Recording')->load(map { $_->all_tracks } @tracklists);
        $c->model('ArtistCredit')->load(map { $_->all_tracks } @tracklists)
            if $c->stash->{inc}->artist;

        my @recordings = map { $_->recording } map { $_->all_tracks } @tracklists;

        $c->model('ISRC')->load_for_recordings(@recordings)
            if $c->stash->{inc}->isrcs;

        $c->model('RecordingPUID')->load_for_recordings(@recordings)
            if ($c->stash->{inc}->puids);
    }

    if ($c->stash->{inc}->release_events) {
        # If we ask for tracks we already have medium stuff loaded
        unless ($release->all_mediums) {
            $c->model('Medium')->load_for_releases($release)
        }

        my @mediums = $release->all_mediums;
        $c->model('MediumFormat')->load(@mediums);
        $c->model('ReleaseLabel')->load($release);
        $c->model('Country')->load($release);

        $c->model('Label')->load($release->all_labels)
            if $c->stash->{inc}->labels;
    }

    if ($c->stash->{inc}->discs) {
        $c->model('Medium')->load_for_releases($release);
        my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
        $c->model('CDTOC')->load(@medium_cdtocs);
    }

    if ($c->stash->{inc}->ratings) {
        # Releases don't have ratings now, so we need to use release groups
        $c->model('ReleaseGroup')->load($release) unless $release->release_group;
        $c->model('ReleaseGroup')->load_meta($release->release_group);
    }

    if ($c->stash->{inc}->counts) {
        $c->model('Medium')->load_for_releases($release)
            unless $c->stash->{inc}->discs ||
                $c->stash->{inc}->release_events;

        $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums)
            unless $c->stash->{inc}->discs;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release', $release, $c->stash->{inc}, $c->stash->{data}));
}

no Moose;
__PACKAGE__->meta->make_immutable;
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
