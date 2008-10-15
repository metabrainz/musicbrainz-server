package MusicBrainz::Server::Form::Release::ConvertToSingleArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub mod_type { ModDefs::MOD_MAC_TO_SAC }

sub build_options
{
    my ($self, $new_artist) = @_;

    my $release = $self->item;

    return {
        album          => $release,
        artistsortname => $new_artist->sort_name,
        artistname     => $new_artist->name,
        artistid       => $new_artist->id,
        movetracks     => 1,
    };
}

1;
