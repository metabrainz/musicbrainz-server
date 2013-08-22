package MusicBrainz::Server::Entity::Role::Age;
use Moose::Role;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::PartialDate;
use Date::Calc qw(N_Delta_YMD Today);
use DateTime;
use List::AllUtils qw( any first_index min pairwise );

has 'begin_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'end_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'ended' => (
    is => 'rw',
    isa => 'Bool',
);

sub period {
    my $self = shift;
    return {
        begin_date => $self->begin_date,
        end_date => $self->end_date,
        ended => $self->ended
    };
}

sub _YMD
{
    my ($self, $partial) = @_;

    my $month = $partial->month ? $partial->month : 1;
    my $day = $partial->day ? $partial->day : 1;

    return ($partial->year, $month, $day);
}

sub has_age
{
    my ($self) = @_;

    # If there is no begin date, there is no age.
    my @begin_comp = $self->begin_date->defined_run or return 0;

    # Only compute ages when the begin date is AD
    return 0 if $self->begin_date->year < 1;

    # The begin date must be before now().
    return 0
        if DateTime->compare(
            DateTime->now,
            DateTime->new(
                year  => $self->begin_date->year,
                month => $self->begin_date->month // 1,
                day   => $self->begin_date->day // 1
            )
        ) == -1;

    # If there is no end date, then the end date is now() (so there is an age).
    my @end_comp = $self->end_date->defined_run or return 1;

    # Shrink @begin_comp and @end_comp to the same size
    my $shortest_run = min(scalar(@begin_comp) - 1, scalar(@end_comp) - 1);
    @begin_comp = @begin_comp[0..$shortest_run];
    @end_comp = @end_comp[0..$shortest_run];

    # Compare all elements that are defined in both @begin_comp and
    # @end_comp to determine if @end_comp is greater than @begin_comp.
    my @comparisons = pairwise { $a <=> $b } @begin_comp, @end_comp;

    my ($LT, $EQ, $GT) = (-1, 0, 1);
    my $first_begin_gt_end = first_index { $_ == $GT } @comparisons;
    my $first_end_gt_begin = first_index { $_ == $LT } @comparisons;

    return
        # An end date component is greater than a begin date component and...
        $first_end_gt_begin > -1 &&
        (
            # No begin date component is greater than end date components or...
            $first_begin_gt_end == -1 ||
            # The first begin date component greater than the end date component
            # is after the first end date component greater than the begin date
            $first_begin_gt_end > $first_end_gt_begin
        );
}

sub age
{
    my ($self) = @_;

    return unless $self->has_age;

    my $begin = $self->begin_date;
    my $end = $self->end_date;

    my @end_YMD = $end->is_empty ? Today : $self->_YMD ($end);
    my ($y, $m, $d) = N_Delta_YMD ($self->_YMD ($begin), @end_YMD);

    return ($y, $m, $d);
}



no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Kuno Woudt

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

