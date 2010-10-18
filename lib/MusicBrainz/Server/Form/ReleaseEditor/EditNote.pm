package MusicBrainz::Server::Form::ReleaseEditor::EditNote;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'editnote'       => ( type => 'TextArea' );
has_field 'as_auto_editor' => ( type => 'Checkbox' );

sub default_as_auto_editor
{
    my $self = shift;
    return $self->ctx->user->is_auto_editor;
};

1;
