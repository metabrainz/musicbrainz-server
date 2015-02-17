package MusicBrainz::Server::Entity::Role::DatePeriod;
use Moose::Role;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw( l );

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
        ended => $self->ended,
    };
}

has 'formatted_date' => (
    is => 'ro',
    builder => '_build_formatted_date',
    lazy => 1,
);

sub _build_formatted_date {
    my ($self) = @_;

    my $begin_date = $self->begin_date;
    my $end_date = $self->end_date;
    my $ended = $self->ended;

    if ($begin_date->is_empty && $end_date->is_empty) {
        return $ended ? l(' &#x2013; ????') : '';
    }
    if ($begin_date->format eq $end_date->format) {
        return $begin_date->format;
    }
    if (!$begin_date->is_empty && !$end_date->is_empty) {
        return l('{begindate} &#x2013; {enddate}',
            { begindate => $begin_date->format, enddate => $end_date->format });
    }
    if ($begin_date->is_empty) {
        return l('&#x2013; {enddate}', { enddate => $end_date->format });
    }
    if ($end_date->is_empty) {
        return l('{begindate} &#x2013;' . ($ended ? ' ????' : ''),
            { begindate => $begin_date->format });
    }
    return '';
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Kuno Woudt, 2012 MetaBrainz Foundation

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

