package MusicBrainz::Server::Form::Field::Compound;

use strict;
use warnings;

use base 'Form::Processor::Field';

sub init_widget { 'compound' }

sub any_input { 1 }

sub init
{
    my ($self) = shift;

    $self->SUPER::init(@_);

    my $profile = $self->profile;

    $self->sub_form(
        MusicBrainz::Server::Form->new(
            parent_field => $self,
            profile      => $profile
        )
    );
}

sub validate
{
    my $self = shift;

    my $sub_form_validated = $self->sub_form->validate(scalar $self->form->params);

    return $sub_form_validated
        unless $sub_form_validated;

    return 1;
}

=head2

Construct a value (that will be accessed by controllers when the form
is valid) from the user input.

For this field, we simply return a hash containing the keys: number,
title and duration.

=cut

sub input_to_value
{
    my $self  = shift;

    my %values = map { $_->name => $_->value } @{ $self->sub_form->fields };

    $self->value(\%values);
}

1;
