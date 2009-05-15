package MusicBrainz::Server::Data::Work;

use Moose;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Data::Utils qw( query_to_list_limited );

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'work JOIN work_name name ON work.name=name.id';
}

sub _columns
{
    return 'work.id, gid, type AS type_id, name.name,
            work.artist_credit AS artist_credit_id, iswc,
            comment, editpending AS edits_pending';
}

sub _id_column
{
    return 'work.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Work';
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = work.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

__PACKAGE__->meta->make_immutable;
no Moose;
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
