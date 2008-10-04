package MusicBrainz::Server::Form::Field::LabelCode;

use strict;
use warnings;

use base 'Form::Processor::Field';

sub validate
{
    my $self = shift;

    return unless $self->SUPER::validate;

    return $self->add_error('This is not a valid label code')
        unless MusicBrainz::Server::Validation::IsValidLabelCode($self->input); 
}

1;
