package MusicBrainz::Server::Entity::PartialDate;
use Moose;

use Date::Calc;
use MusicBrainz::Server::Data::Utils qw( take_while );

use overload '<=>' => \&_cmp, fallback => 1;

has 'year' => (
    is => 'ro',
    isa => 'Maybe[Int]',
    predicate => 'has_year',
);

has 'month' => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

has 'day' => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    return $class->$orig( @_ ) unless @_ == 1;

    my $info = shift;
    if (!ref($info) && defined($info)
        && $info =~ /^ (?: (-?\d{1,4} | \?\?\?\?) (?: -? (\d{1,2} | \?\?) (?: -? (\d{1,2}) )? )? )? $/x)
    {
        $info = {};
        $info->{year} = $1 if (defined $1 && $1 ne '????');
        $info->{month} = $2 if ($2 && $2 ne '??' && $2 > 0);
        $info->{day} = $3 if ($3 && $3 > 0);
        return $class->$orig( $info );
    }

    $info = {} if !ref($info); # if parsing failed

    my %info = map { $_ => $info->{$_} }
        grep { defined($info->{$_}) } keys %$info;

    return $class->$orig( %info );
};

has is_empty => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    builder => '_build_is_empty',
);

sub _build_is_empty {
    my ($self) = @_;
    return !(defined $self->year || $self->month || $self->day);
}

has format => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_format',
);

sub _build_format {
    my ($self) = @_;

    return '' if $self->is_empty;

    my ($year, $month, $day, $result) =
        ($self->year, $self->month, $self->day, '');

    if (defined $year) {
        $result .= (sprintf '%04d', $year);
    } elsif ($month || $day) {
        $result .= '????';
    }

    if ($month) {
        $result .= '-' . (sprintf '%02d', $month);
    } elsif ($day) {
        $result .= '-??';
    }

    $result .= '-' . (sprintf '%02d', $day) if $day;

    return $result;
}

=attribute defined_run

Return all parts of the date that are defined, returning at the first
undefined value.

=cut

has defined_run => (
    isa => 'ArrayRef[Int]',
    lazy => 1,
    builder => '_build_defined_run',
    traits => ['Array'],
    handles => {defined_run => 'elements'},
);

sub _build_defined_run {
    my $self = shift;
    my @components = ($self->year, $self->month, $self->day);
    return [take_while { defined } @components];
}

sub _cmp
{
    my ($a, $b) = @_;

    # Stuff without a year sorts first too
    return  0 if (!defined($a->year) && !defined($b->year));
    return  1 if ( defined($a->year) && !defined($b->year));
    return -1 if (!defined($a->year) &&  defined($b->year));

    # Date::Calc can't understand years <= 0, so we special case this sorting
    if ($a->year <= 0 || $b->year <= 0) {
        return
            $a->year <=> $b->year ||
            (($a->month // 1) <=> ($b->month // 1)) ||
            (($a->day // 1)   <=> ($b->day // 1));
    }

    # We have years for both dates, we can now assume real sorting
    my @begin = ($a->year, $a->month || 1, $a->day || 1);
    my @end =   ($b->year, $b->month || 1, $b->day || 1);

    # Sort invalid dates first. Should make it obvious something is broken :)
    return  0 if (!Date::Calc::check_date(@begin) && !Date::Calc::check_date(@end));
    return  1 if (!Date::Calc::check_date(@end));
    return -1 if (!Date::Calc::check_date(@begin));

    my ($days) = Date::Calc::Delta_Days(@begin, @end);

    return $days > 0 ? -1
         : $days < 0 ?  1
         :              0;
}

sub new_from_row {
    my ($class, $row, $prefix) = @_;
    $prefix //= '';
    my %info;
    $info{year} = $row->{$prefix . 'year'} if defined $row->{$prefix . 'year'};
    $info{month} = $row->{$prefix . 'month'} if defined $row->{$prefix . 'month'};
    $info{day} = $row->{$prefix . 'day'} if defined $row->{$prefix . 'day'};
    return $class->new(%info);
}

sub TO_JSON {
    my ($self) = @_;

    return {
        year => $self->year,
        month => $self->month,
        day => $self->day,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
