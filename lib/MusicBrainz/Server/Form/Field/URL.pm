package MusicBrainz::Server::Form::Field::URL;
use Moose;

use MusicBrainz::Server::Validation qw( is_valid_url );

extends 'HTML::FormHandler::Field::Text';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;

    return $self->add_error('Enter a valid url "e.g. http://google.com/"')
        unless is_valid_url($url);

    $self->_set_value($url);
}

__PACKAGE__->meta->make_immutable;
1;
