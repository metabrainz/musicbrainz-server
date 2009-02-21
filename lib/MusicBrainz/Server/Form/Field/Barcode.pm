package MusicBrainz::Server::Form::Field::Barcode;

use strict;
use warnings;

use base 'Form::Processor::Field::Text';

use MusicBrainz::Server::Validation;

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    return $self->add_error("This is not a valid barcode")
        unless MusicBrainz::Server::Validation::IsValidEAN($self->input);
}

1;
