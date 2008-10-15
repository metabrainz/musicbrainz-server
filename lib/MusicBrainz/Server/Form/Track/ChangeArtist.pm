package MusicBrainz::Server::Form::Track::ChangeArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub mod_type { ModDefs::MOD_CHANGE_TRACK_ARTIST }

sub build_options
{
    my ($self, $new_artist) = @_;

    my $track = $self->item;

    # Load the track artist fully
    $track->artist->LoadFromId;

    return {
        track          => $track,
        oldartist      => $track->artist,
        artistname     => $new_artist->name,
        artistsortname => $new_artist->sort_name,
        artistid       => $new_artist->id,
    };
}

1;
