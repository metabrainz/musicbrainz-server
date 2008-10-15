package MusicBrainz::Server::Form::Release::Move;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

use ModDefs;
use Moderation;

sub profile
{
    return {
        optional => {
            edit_note => 'TextArea',
            move_tracks => 'Checkbox',
        }
    };
}

sub mod_type { ModDefs::MOD_MOVE_RELEASE }

sub build_options
{
    my ($self, $new_artist) = @_;

    my $release = $self->item;

    return {
        album          => $release,
        oldartist      => $artist,
        artistname     => $new_artist->name,
        artistsortname => $new_artist->sort_name,
        artistid       => $new_artist->id,
        movetracks     => $self->value('move_tracks'),
    };
}

1;
