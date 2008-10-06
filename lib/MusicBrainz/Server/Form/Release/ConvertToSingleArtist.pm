package MusicBrainz::Server::Form::Release::ConvertToSingleArtist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub set_artist
{
    my ($self, $new_artist) = @_;

    my $user    = $self->context->user;
    my $release = $self->item;

    my @mods = Moderation->InsertModeration(
        DBH => $self->context->mb->{DBH},
        uid => $user->id,
        privs => $user->privs,
        type => ModDefs::MOD_MAC_TO_SAC,

        album          => $release,
        artistsortname => $new_artist->sort_name,
        artistname     => $new_artist->name,
        artistid       => $new_artist->id,
        movetracks     => 1,
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

1;
