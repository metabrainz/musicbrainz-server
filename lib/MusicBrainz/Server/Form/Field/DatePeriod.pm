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

    return if !Date::Calc::check_date($begin->{year}, $begin->{month} || 1, $begin->{day} || 1);
    return if !Date::Calc::check_date($end->{year}, $end->{month} || 1, $end->{day} || 1);

    if ($end->{year} || $end->{month} || $end->{day}) {
        $self->field('ended')->value(1);
    }

    return 1 unless $begin->{year} && $end->{year};

    my ($days) = Date::Calc::Delta_Days(
        $begin->{year}, $begin->{month} || 1, $begin->{day} || 1,
        $end->{year},   $end->{month} || 1,   $end->{day} || 1
    );

    if ($days < 0) {
        return $self->field('end_date')->add_error(l('The end date must occur on or after the begin date'));
    }

    return 1;
};

1;
