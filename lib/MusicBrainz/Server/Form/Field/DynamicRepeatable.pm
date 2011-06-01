package MusicBrainz::Server::Form::Field::DynamicRepeatable;
use Moose;

extends 'HTML::FormHandler::Field::Repeatable';

sub append {
    my $self = shift;
    my $index = $self->index;
    my $field = $self->clone_element(0);
    $field->name($index);
    $self->add_field($field);
    $self->index($index + 1);
    return $field;
}

1;
