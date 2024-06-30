package MusicBrainz::Server::Form::Field::PartialDate;
use strict;
use warnings;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_partial_date );
use Scalar::Util qw( looks_like_number );
use HTML::FormHandler::Moose;
use Date::Calc ();

extends 'HTML::FormHandler::Field::Compound';

has_field 'year' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    inflate_method => sub {
        my $year = $_[1];
        return undef if !defined $year;
        $year++ if $year < 0;
        return $year;
    },
    deflate_method => sub {
        my $year = $_[1];
        return undef if !defined $year;
        $year-- if $year <= 0;
        return sprintf '%.4d', $year;
    },
);

has_field 'month' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    range_start => 1,
    range_end => 12,
);

has_field 'day' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    range_start => 1,
    range_end => 31,
);

=begin comment

This is kind of hacky. If the user doesn't enter any data, the form will
submit with:

    year => ''
    month => ''
    day => ''

However, in this case we really need:

    year => undef,
    month => undef,
    day => undef

=cut

around '_set_value' => sub
{
    my $orig = shift;
    my ($self, $value) = @_;

    $self->$orig({
        map {
            $_ => !defined $value->{$_} || $value->{$_} eq ''
                ? undef : $value->{$_}
        } keys %$value,
    });
};

sub validate {
    my $self = shift;

    my $year = $self->field('year')->value;
    my $month = $self->field('month')->value;
    my $day = $self->field('day')->value;

    my $input_year = $self->field('year')->input;
    if (looks_like_number($input_year) && $input_year == 0) {
        return $self->add_error(l('0 is not a valid year.'));
    }

    return 1 if is_valid_partial_date($year, $month, $day);

    return $self->add_error(l('invalid date'));
}

1;
