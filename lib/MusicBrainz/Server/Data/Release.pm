package MusicBrainz::Server::Data::Release;

use Moose;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'release JOIN release_name name ON release.name=name.id';
}

sub _columns
{
    return 'release.id, gid, name.name, artist_credit, release_group, ' .
           'status, packaging, date_year, date_month, date_day, ' .
           'comment, editpending, barcode';
}

sub _id_column
{
    return 'release.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        artist_credit_id => 'artist_credit',
        release_group_id => 'release_group',
        status_id => 'status',
        packaging_id => 'packaging',
        date => sub { partial_date_from_row(shift, 'date_') },
        edits_pending => 'editpending',
        comment => 'comment',
        barcode => 'barcode',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Release';
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
