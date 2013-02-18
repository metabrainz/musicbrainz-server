package MusicBrainz::Server::Form::Field::DatePeriod;

use HTML::FormHandler::Moose;
use Date::Calc;
use List::MoreUtils 'any';
use MusicBrainz::Server::Translation qw( l ln );
extends 'HTML::FormHandler::Field::Compound';

has_field 'begin_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
    not_nullable => 1
);

has_field 'end_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
    not_nullable => 1
);

has_field 'ended' => (
    type => 'Checkbox'
);

after 'validate' => sub {
    my $self = shift;
    my $begin = $self->field('begin_date')->value;
    my $end   = $self->field('end_date')->value;

    return if any { $_->has_errors } map { $_->fields }
        $self->field('begin_date'), $self->field('end_date');

    # If we got here, the dates are valid partial dates but may not be valid full dates
    return if !Date::Calc::check_date($begin->{year}, $begin->{month} || 1, $begin->{day} || 1);
    # Use a default year in case of a completely absent end date
    return if !Date::Calc::check_date($end->{year}, $end->{month} || 12,
                   $end->{day} || Date::Calc::Days_in_Month($end->{year} || 1, $end->{month} || 12));

    if ($end->{year} || $end->{month} || $end->{day}) {
        $self->field('ended')->value(1);
    }

    return 1 unless $begin->{year} && $end->{year};

    # Use the end of the year/month so the end date can be less precise than the begin date
    my ($days) = Date::Calc::Delta_Days(
        $begin->{year}, $begin->{month} || 1, $begin->{day} || 1,
        $end->{year},   $end->{month} || 12,   $end->{day} || Date::Calc::Days_in_Month($end->{year}, $end->{month} || 12)
    );

    if ($days < 0) {
        return $self->field('end_date')->add_error(l('The end date must occur on or after the begin date'));
    }

    return 1;
};

1;
