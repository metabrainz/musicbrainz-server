package MusicBrainz::Server::Form::Track::ChangeArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub change_artist
{
    my ($self, $new_artist) = @_;

    my $user  = $self->context->user;
    my $track = $self->item;

    # Load the track artist fully
    $track->artist->LoadFromId;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_CHANGE_TRACK_ARTIST,

        track          => $track,
        oldartist      => $track->artist,
        artistname     => $new_artist->name,
        artistsortname => $new_artist->sort_name,
        artistid       => $new_artist->id,
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

1;
