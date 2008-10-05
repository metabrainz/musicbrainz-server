package MusicBrainz::Server::Form::Release::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub remove_release
{
    my ($self) = @_;

    my $release = $self->item;
    my $user    = $self->context->user;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_REMOVE_RELEASE,

        album => $release
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

1;
