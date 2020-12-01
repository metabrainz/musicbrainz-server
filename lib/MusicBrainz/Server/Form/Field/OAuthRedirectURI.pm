package MusicBrainz::Server::Form::Field::OAuthRedirectURI;
use URI;
use Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'HTML::FormHandler::Field::Text';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;
    $url = URI->new($url)->canonical;

    $self->_set_value($url->as_string);
}

__PACKAGE__->meta->make_immutable;
1;
