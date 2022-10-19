package MusicBrainz::Server::Form::Field::PartialDate;
use strict;
use warnings;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_partial_date );
use HTML::FormHandler::Moose;
use Date::Calc ();

extends 'HTML::FormHandler::Field::Compound';

has_field 'year' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    deflate_method => sub { defined $_[1] ? sprintf '%.4d', $_[1] : undef },
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
        } keys %$value
    });
};

sub validate {
    my $self = shift;

    my $year = $self->field('year')->value;
    my $month = $self->field('month')->value;
    my $day = $self->field('day')->value;

    return 1 if is_valid_partial_date($year, $month, $day);

    return $self->add_error(l('invalid date'));
}

1;
