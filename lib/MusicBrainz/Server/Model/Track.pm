package MusicBrainz::Server::Model::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Adapter 'LoadEntity';

sub load
{
    my ($self, $mbid) = @_;

    my $track = MusicBrainz::Server::Track->new($self->dbh);
    LoadEntity($track, $mbid);

    return $track;
}

sub load_from_release
{
    my ($self, $release) = @_;

    my @tracks = $release->LoadTracks;
    my $puid_counts = $release->LoadPUIDCount;

    return [ map
    {
        my $track = $_;
        $track->{puid_count} = $puid_counts->{ $track->id };

        $track->artist->LoadFromId;
        $track;
    } @tracks ];
}

sub add_non_album_track
{
    my ($self, $artist, $track, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_ADD_TRACK_KV,

        artist      => $artist,
        trackname   => $track->name,
        tracklength => $track->length || 0,
    );
}

1;
