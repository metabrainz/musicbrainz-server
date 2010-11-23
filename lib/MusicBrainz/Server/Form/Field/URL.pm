package MusicBrainz::Server::Form::Field::URL;
use URI;
use Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_url );

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => (
    default => 255
);

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;
    $url = URI->new($url)->canonical->as_string;

    return $self->add_error(l('Enter a valid url e.g. "http://google.com/"'))
        unless is_valid_url($url);

    $self->_set_value($url);
}

sub deflate {
    my ($self, $value) = @_;
    return $value->as_string;
}

__PACKAGE__->meta->make_immutable;
1;
