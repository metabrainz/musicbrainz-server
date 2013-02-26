package MusicBrainz::Server::Form::Field::DatePeriod;

use HTML::FormHandler::Moose;
use Date::Calc;
use List::MoreUtils 'any';
use MusicBrainz::Server::Translation qw( l ln );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
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

    return if any { $_->has_errors } map { $_, $_->fields }
        $self->field('begin_date'), $self->field('end_date');

    if ($end->{year} || $end->{month} || $end->{day}) {
        $self->field('ended')->value(1);
    }

    return 1 unless $begin->{year} && $end->{year};

    if (PartialDate->new($begin) > PartialDate->new($end)) {
        return $self->field('end_date')->add_error(l('The end date must occur on or after the begin date'));
    }

    return 1;
};

1;
