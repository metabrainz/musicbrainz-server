package MusicBrainz::Server::Form::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Track;

sub profile
{
    {
        required => {
            name   => 'Text',
            number => '+MusicBrainz::Server::Form::Field::TrackNumber',
        },
        optional => {
            duration  => '+MusicBrainz::Server::Form::Field::Time',
            edit_note => 'TextArea',
        }
    }
}

sub update_model
{
    my $self = shift;
    my $item = $self->item;

    my $user = $self->context->user;

    my %mod_base = (
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privileges,

        track => $item->get_track,
    );

    my $has_edit_note = $self->value('edit_note') =~ /\S/;

    # Track number:
    if ($self->value('number') ne $item->number)
    {
        my %moderation = %mod_base;
        $moderation{type}   = ModDefs::MOD_EDIT_TRACKNUM;
        $moderation{newseq} = $self->value('number');

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    if ($self->value('name') ne $item->name)
    {
        my %moderation = %mod_base;
        $moderation{type}    = ModDefs::MOD_EDIT_TRACKNAME;
        $moderation{newname} = $self->value('name');

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    if ($self->value('duration') ne MusicBrainz::Server::Track::UnformatTrackLength($item->duration))
    {
        my %moderation = %mod_base;
        $moderation{type}      = ModDefs::MOD_EDIT_TRACKTIME;
        $moderation{newlength} = $self->value('duration');

        my @mods = Moderation->InsertModeration(%moderation);
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $has_edit_note;
    }

    return 1;
}

sub update_from_form
{
    my ($self, $data) = @_;

    $self->validate($data) and $self->update_model;
}

1;
