package MusicBrainz::Server::Form::Field::OAuthRedirectURI;
use URI;
use Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'HTML::FormHandler::Field::Text';

my %ALLOWED_PROTOCOLS = map { $_ => 1 } qw( http https );

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;
    $url = URI->new($url)->canonical;

    return $self->add_error(l('URL protocol must be HTTP or HTTPS'))
        unless exists $ALLOWED_PROTOCOLS{ lc($url->scheme) };

    $self->_set_value($url->as_string);
}

sub deflate {
    my ($self, $value) = @_;
    return $value->as_string;
}

__PACKAGE__->meta->make_immutable;
1;
