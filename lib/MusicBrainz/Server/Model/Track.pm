package MusicBrainz::Server::Model::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Facade::Track;

sub load
{
    my ($self, $mbid) = @_;

    my $track = MusicBrainz::Server::Track->new($self->dbh);
    LoadEntity($track, $mbid);

    return MusicBrainz::Server::Facade::Track->new_from_track($track);
}

sub load_from_release
{
    my ($self, $release) = @_;

    my @tracks = $release->LoadTracks;
    my $puid_counts = $release->LoadPUIDCount;

    return [ map
    {
        my $track = MusicBrainz::Server::Facade::Track->new_from_track($_);
        $track->puid_count($puid_counts->{ $track->id });

        $track;
    } @tracks ];
}

1;
