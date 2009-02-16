package MusicBrainz::Server::Form::Field::URL;

use strict;
use warnings;

use base 'Form::Processor::Field::Text';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    my $url = $self->input;

    return $self->add_error('Enter a valid url "e.g. http://google.com/"')
        unless MusicBrainz::Server::URL->IsLegalURL($url);

    return 1;
}

1;
