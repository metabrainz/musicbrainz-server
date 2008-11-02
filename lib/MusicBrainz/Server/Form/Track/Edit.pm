package MusicBrainz::Server::Form::Track::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Track::Base';

sub update_model
{
    my $self = shift;

    my $track = $self->item;
    my $user  = $self->context->user;

    my %mod_base = (
        DBH       => $self->context->mb->{DBH},
        moderator => $user,

        track => $track,
    );

    my $has_edit_note = $self->value('edit_note') =~ /\S/;

    # Track number:
    if ($self->value('track')->{number} ne $track->sequence)
    {
        my %moderation = %mod_base;
        $moderation{type}   = ModDefs::MOD_EDIT_TRACKNUM;
        $moderation{newseq} = $self->value('track')->{number};

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    # Track name:
    if ($self->value('track')->{name} ne $track->name)
    {
        my %moderation = %mod_base;
        $moderation{type}    = ModDefs::MOD_EDIT_TRACKNAME;
        $moderation{newname} = $self->value('track')->{name};

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    # Track Duration
    if ($self->value('track')->{duration} ne $track->length)
    {
        my %moderation = %mod_base;
        $moderation{type}      = ModDefs::MOD_EDIT_TRACKTIME;
        $moderation{newlength} = $self->value('track')->{duration};

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    return 1;
}

1;
