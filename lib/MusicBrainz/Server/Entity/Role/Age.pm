package MusicBrainz::Server::Entity::Role::Age;
use Moose::Role;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::PartialDate;
use Date::Calc qw(N_Delta_YMD Today);
use DateTime;

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

our $mock_now;

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

    my $now = $mock_now || DateTime->now;

    # Must have a begin date
    return 0 if     $self->begin_date->is_empty;

    # Must have a begin year
    return 0 unless $self->begin_date->has_year &&
                    $self->begin_date->year > 0;

    # The begin date must be before now()
    my $begin = DateTime->new(
        year  => $self->begin_date->year,
        month => $self->begin_date->month // 1,
        day   => $self->begin_date->day // 1
    );
    return 0 if DateTime->compare($now, $begin) == -1;

    # The absence of an end date means an age is possible
    return 1 if $self->end_date->is_empty;

    # Otherwise, an end date must have a year and be before the begin date
    return 0 unless $self->end_date->has_year;
    return 1 if $self->end_date->year          >  $self->begin_date->year;
    return 1 if ($self->end_date->month // 12) > ($self->begin_date->month // 1);
    return 1 if ($self->end_date->day // 31)   > ($self->begin_date->day   // 1);

    return 0;
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

