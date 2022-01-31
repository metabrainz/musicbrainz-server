package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils;
use MusicBrainz::Server::Translation qw( l );

extends 'HTML::FormHandler::Field::Text';

after validate => sub {
    my $self = shift;

    my $value = $self->value;
    my $trimmed = MusicBrainz::Server::Data::Utils::trim($value);
    if (length $value && !length $trimmed) {
        # This error triggers if the entered text consists entirely of
        # invalid characters. However, text that is only whitespace
        # generally triggers the "Required field" error first.
        return $self->push_errors(
            l('The characters you’ve entered are invalid or not allowed.')
        );
    }
    $self->value($trimmed);
};

1;
