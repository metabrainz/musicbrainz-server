package MusicBrainz::Server::Form::Moderation::AddNote;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'add-moderation-note' }

sub profile
{
    return {
        required => {
            edit_note => 'TextArea',
        }
    };
}

sub insert
{
    my ($self) = @_;

    my $moderation = $self->item;
    my $user       = $self->context->user;

    $moderation->InsertNote($user->id, $self->value('edit_note'));
}

1;
