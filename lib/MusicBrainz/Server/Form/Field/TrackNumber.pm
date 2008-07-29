package MusicBrainz::Server::Form::Field::TrackNumber;

use strict;
use warnings;

use base 'Form::Processor::Field::Integer';

sub style { 'field_type_tracknumber' }

sub validate
{
    my $self = shift;

    return
        unless $self->Form::Processor::Field::Integer::validate;

    return $self->add_error('Must be positive')
        unless $self->input > 0;
}

1;
