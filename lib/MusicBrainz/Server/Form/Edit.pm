package MusicBrainz::Server::Form::Edit;
use HTML::FormHandler::Moose::Role;

requires 'edit_field_names';

has_field 'edit_note' => (
    type => 'TextArea',
    label => 'Edit note:',
);

sub edit_fields
{
    my ($self) = @_;
    return grep {
        $_->has_input || $_->has_value
    } map {
        $self->field($_)
    } $self->edit_field_names;
}

1;
