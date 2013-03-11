package MusicBrainz::Server::Form::Field::PartialDate;
use MusicBrainz::Server::Translation qw( l );
use HTML::FormHandler::Moose;
use Date::Calc ();

extends 'HTML::FormHandler::Field::Compound';

has_field 'year' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
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

    # anything partial cannot be checked, and is therefore considered valid.
    return 1 unless ($year && $month && $day);

    return 1 if Date::Calc::check_date ($year, $month, $day);

    return $self->add_error (l("invalid date"));
}

1;
