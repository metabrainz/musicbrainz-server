package MusicBrainz::Server::Data::Artist;

use Moose;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'artist ' .
           'JOIN artist_name name ON artist.name=name.id ' .
           'JOIN artist_name sortname ON artist.sortname=sortname.id';
}

sub _columns
{
    return 'artist.id, gid, name.name, sortname.name AS sortname, ' .
           'type, country, gender, editpending, ' .
           'begindate_year, begindate_month, begindate_day, ' .
           'enddate_year, enddate_month, enddate_day, comment';
}

sub _id_column
{
    return 'artist.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sortname',
        type_id => 'type',
        country_id => 'country',
        gender_id => 'gender',
        begin_date => sub { partial_date_from_row(shift, 'begindate_') },
        end_date => sub { partial_date_from_row(shift, 'enddate_') },
        edits_pending => 'editpending',
        comment => 'comment',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Artist';
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
