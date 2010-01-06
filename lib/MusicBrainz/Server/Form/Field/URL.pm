package MusicBrainz::Server::Form::Field::URL;
use Moose;

extends 'HTML::FormHandler::Field::Text';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->value;

    return $self->add_error('Enter a valid url "e.g. http://google.com/"')
        unless MusicBrainz::Server::URL->IsLegalURL($url);

    $self->_set_value($url);
}

__PACKAGE__->meta->make_immutable;
1;
