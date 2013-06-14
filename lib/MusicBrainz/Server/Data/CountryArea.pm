package MusicBrainz::Server::Data::CountryArea;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Area;
use MusicBrainz::Server::Data::Utils qw( query_to_list );

extends 'MusicBrainz::Server::Data::Area';
with 'MusicBrainz::Server::Data::Role::SelectAll' => { order_by => [ 'name ASC' ] };

around '_get_all_from_db' => sub {
    my ($orig, $self, $p) = @_;
    my $query = "SELECT " . $self->_columns .
        " FROM country_area ca JOIN area ON ca.area = area.id " .
        " ORDER BY " . (join ", ", @{ $p->order_by });
    return query_to_list($self->c->sql, sub { $self->_new_from_row(shift) }, $query);
};

sub sort_in_forms { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
