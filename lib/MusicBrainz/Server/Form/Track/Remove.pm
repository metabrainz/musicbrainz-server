package MusicBrainz::Server::Form::Track::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

use Moderation;
use ModDefs;

sub remove_from_release
{
    my ($self, $release) = @_;
    
    my $user  = $self->context->user;
    my $track = $self->item;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_REMOVE_TRACK,

        track => $track,
        album => $release,
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $self->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

1;
