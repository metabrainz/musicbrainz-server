package MusicBrainz::Server::Form::Field::URL;
use URI;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_url );

extends 'HTML::FormHandler::Field::Text';

has '+deflate_method' => (
    default => sub { \&deflate_url }
);

my %ALLOWED_PROTOCOLS = map { $_ => 1 } qw( http https ftp );

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;
    $url = URI->new($url)->canonical;

    return $self->add_error(l('Enter a valid url e.g. "http://google.com/"'))
        unless is_valid_url($url->as_string);

    return $self->add_error(l('URL protocol must be HTTP, HTTPS or FTP'))
        unless exists $ALLOWED_PROTOCOLS{ lc($url->scheme) };

    $self->_set_value($url->as_string);
}

sub deflate_url {
    my ($self, $value) = @_;

    return $value->as_iri;
}

__PACKAGE__->meta->make_immutable;
1;
