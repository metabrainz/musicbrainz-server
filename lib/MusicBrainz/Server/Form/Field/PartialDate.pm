package MusicBrainz::Server::Form::Field::PartialDate;
use HTML::FormHandler::Moose;
use Date::Calc ();

extends 'HTML::FormHandler::Field::Compound';

has_field 'year' => (
    type => 'Integer',
    required => 1,
);

has_field 'month' => (
    type => 'Integer',
    range_start => 1,
    range_end => 12,
);

has_field 'day' => (
    type => 'Integer',
    range_start => 1,
    range_end => 31,
);

sub validate {
    my $self = shift;

    my $year = $self->field('year')->value;
    my $month = $self->field('month')->value;
    my $day = $self->field('day')->value;

    # anything partial cannot be checked, and is therefore considered valid.
    return 1 unless ($year && $month && $day);

    return 1 if Date::Calc::check_date ($year, $month, $day);

    return $self->add_error ("invalid date");
}

1;
