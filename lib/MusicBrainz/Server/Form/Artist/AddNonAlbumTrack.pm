package MusicBrainz::Server::Form::Artist::AddNonAlbumTrack;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            track => {
                type => '+MusicBrainz::Server::Form::Field::Track',

                # Don't require a track number for non album tracks
                with_track_number => 0, 
            }
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub add_track
{
    my $self = shift;

    my $artist = $self->item;
    my $user   = $self->context->user;

    my $edit = Moderation->new('MOD_ADD_TRACK_KV');

    my @mods = $edit->insert(
        DBH   => $self->context->mb->{DBH},
        user  => $user,

        artist      => $artist,
        trackname   => $self->value('track')->{name},
        tracklength => $self->value('track')->{duration} || 0,
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;

        return \@mods;
    }
    else
    {
        die "Could not insert track";
    }
}

1;
