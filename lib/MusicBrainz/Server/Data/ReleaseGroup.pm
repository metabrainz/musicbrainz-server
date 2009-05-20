package MusicBrainz::Server::Data::ReleaseGroup;

use Moose;
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Data::Utils qw( load_subobjects query_to_list_limited );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::AnnotationRole';

sub _annotation_type
{
    return 'release_group';
}

sub _table
{
    return 'release_group rg JOIN release_name name ON rg.name=name.id';
}

sub _columns
{
    return 'rg.id, gid, type AS type_id, name.name,
            rg.artist_credit AS artist_credit_id,
            comment, editpending AS edits_pending';
}

sub _id_column
{
    return 'rg.id';
}

sub _gid_redirect_table
{
    return 'release_group_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseGroup';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release_group', @objs);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = rg.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY rg.type, name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::ReleaseGroup

=head1 METHODS

=head2 load (@releases)

Loads and sets release groups for the specified releases.

=head2 find_by_artist ($artist_id, $limit, [$offset])

Finds release groups by the specified artist, and returns an array containing
a reference to the array of release groups and the total number of found
release groups. The $limit parameter is used to limit the number of returned
release groups.

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
