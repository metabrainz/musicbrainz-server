package MusicBrainz::Server::Form::Field::Time;

use strict;
use warnings;

use base 'Form::Processor::Field::Text';

use MusicBrainz::Server::Track;
use MusicBrainz::Server::Validation;

sub input_to_value
{
    my ($self) = @_;

    $self->value(MusicBrainz::Server::Track::UnformatTrackLength($self->input));
}

sub validate
{
    my ($self) = @_;

    return
        unless $self->Form::Processor::Field::Text::validate;

    return $self->add_error('This is not a valid time')
        unless MusicBrainz::Server::Validation::IsNonNegInteger(_fmt($self->input));
}

sub _fmt
{
    return MusicBrainz::Server::Track::UnformatTrackLength($_[0]);
}

1;
