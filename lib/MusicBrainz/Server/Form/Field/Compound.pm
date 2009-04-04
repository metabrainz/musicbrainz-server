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
        Form::Processor->new(
            parent_field => $self,
            profile      => $profile,
            name         => $self->form->name . '-' . $self->name,
        )
    );

    for my $field ($self->sub_form->fields)
    {
        my $method = 'options_' . $field->name;
        if ($self->can($method))
        {
            $self->sub_form->load_field_options($field, $self->$method);
        }
    }
}

sub name
{
    my $self = shift;

    if (scalar @_)
    {
        # Setting name? Let Form::Processor::Field do that
        $self->SUPER::name(@_);
    }
    else
    {
        # Getting name - act more like full_name
        my $name = $self->SUPER::name;

        my $form = $self->form           || return $name;
        my $parent = $form->parent_field || return $name;

        return $parent->full_name . qw{.} . $name;
    }
}

sub validate
{
    my $self = shift;

    $self->sub_form->validate(scalar $self->form->params) or return;
    $self->extra_validation or return;

    return 1;
}

=head2 extra_validation

Perform any extra validation, after field validation is complete

=cut

sub extra_validation { 1 }

=head2 errors

Return a list of errors for all sub fields.

=cut

sub errors
{
    my $self = shift;
    my @field_errors = map {
        $_->errors
    } $self->sub_form->fields;

    my @errors = ($self->SUPER::errors, @field_errors);
    return @errors;
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

    my %values = map { $_->SUPER::name => $_->value } @{ $self->sub_form->fields };

    $self->value(\%values);
}

=head2 value

Setting the value attemps to the value of the compound field's subfields.

=cut

sub value
{
    my $self  = shift;
    my ($obj) = @_;

    # The best we can do is attempt to set each field's value
    # to the value of that attribute in the value object
    if (defined $obj && ref $obj ne 'HASH')
    {
        for my $field ($self->sub_form->fields)
        {
            my $name  = $field->name;
            my $value = $self->field_value($name, $obj);

            unless (defined $value)
            {
                $value = $obj->$name
                    if $obj && $obj->can($name);
            }

            $field->value($value);
        }
    }

    return $self->SUPER::value(@_);
}

sub field_value { undef; }

1;
