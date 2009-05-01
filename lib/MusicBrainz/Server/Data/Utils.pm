package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use MusicBrainz::Server::Entity::PartialDate;

our @EXPORT_OK = qw( partial_date_from_row );

sub partial_date_from_row
{
    my ($row, $prefix) = @_;
    my %info;
    $info{year} = $row->{$prefix . 'year'} if defined $row->{$prefix . 'year'};
    $info{month} = $row->{$prefix . 'month'} if defined $row->{$prefix . 'month'};
    $info{day} = $row->{$prefix . 'day'} if defined $row->{$prefix . 'day'};
    return MusicBrainz::Server::Entity::PartialDate->new(%info);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
