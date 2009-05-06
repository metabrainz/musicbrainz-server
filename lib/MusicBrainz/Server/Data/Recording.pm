package MusicBrainz::Server::Data::Recording;

use Moose;
use MusicBrainz::Server::Entity::Recording;

extends 'MusicBrainz::Server::Data::CoreEntity';

sub _table
{
    return 'recording JOIN track_name name ON recording.name=name.id';
}

sub _columns
{
    return 'recording.id, gid, name.name, ' .
           'artist_credit AS artist_credit_id, length, ' .
           'comment, editpending AS edits_pending';
}

sub _id_column
{
    return 'recording.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Recording';
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
