package MusicBrainz::Server::Form::Field::Track;

use strict;
use warnings;

use base 'Form::Processor::Field';

use Rose::Object::MakeMethods::Generic(
    boolean => [ with_track_number => { default => 1 } ],
);

=head1 NAME

MusicBrainz::Server::Form::Field::Track

=head1 DESCRIPTION

Provides a compound field that supports track number, title and duration

=head1 METHODS

=head2 init_widget

This field has type 'track' - which we specialise on in forms/input.tt
to draw the 3 separate input fields

=cut

sub init_widget { 'compound' }

sub any_input { 1 }

sub init
{
    my ($self) = shift;

    $self->SUPER::init(@_);

    my $profile = {
        required => {
            name   => 'Text',
            duration => '+MusicBrainz::Server::Form::Field::Time',
        },
        optional => {
        }
    };

    if ($self->with_track_number)
    {
        $profile->{required}->{number} = '+MusicBrainz::Server::Form::Field::TrackNumber',
    }

    $self->sub_form(
        MusicBrainz::Server::Form->new(
            parent_field => $self,
            profile      => $profile,
        )
    );
}

sub validate
{
    my $self = shift;

    $self->sub_form->validate(scalar $self->form->params)
        or return undef;

    return 1;
}

1;
