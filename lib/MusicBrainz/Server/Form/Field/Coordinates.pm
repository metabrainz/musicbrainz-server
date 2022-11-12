package MusicBrainz::Server::Form::Field::Coordinates;
use utf8;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use List::AllUtils qw( first );
use MusicBrainz::Server::Validation qw( validate_coordinates );

extends 'MusicBrainz::Server::Form::Field::Text';

has '+deflate_method' => (
    default => sub { \&deflate_coordinates }
);

has '+validate_when_empty' => (
    default => 1
);

my %DIRECTIONS = ( n => 1, s => -1, e => 1, w => -1 );

sub reverse_direction {
    my ($number, $is_latitude) = @_;
    my @dirs;
    if ($is_latitude) {
        @dirs = qw( n s );
    } else {
        @dirs = qw( e w );
    }
    my $direction = first { ($number > 0) eq ($DIRECTIONS{lc $_} > 0) } @dirs;
    return $number * $DIRECTIONS{$direction} . uc $direction
}

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    my $coordinates = $self->value;

    if ($coordinates =~ /^\s*$/) {
        $self->value(undef);
        return;
    }

    $coordinates = validate_coordinates($coordinates);

    if ($coordinates) {
        $self->value({
            latitude => $coordinates->{latitude},
            longitude => $coordinates->{longitude},
        });
        return;
    }

    $self->value(undef);
    return $self->add_error(l('These coordinates could not be parsed'));
}

sub deflate_coordinates {
    my ($self, $value) = @_;
    if (defined $value && defined $value->latitude && defined $value->longitude) {
        return join(', ',
                    reverse_direction($value->latitude, 1),
                    reverse_direction($value->longitude, 0));
    }
}

1;
