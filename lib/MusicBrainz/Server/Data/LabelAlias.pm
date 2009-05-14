package MusicBrainz::Server::Data::LabelAlias;
use Moose;

use MusicBrainz::Server::Entity::LabelAlias;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'label_alias JOIN label_name name ON label_alias.name=name.id';
}

sub _columns
{
    return 'label_alias.id, name.name, label, editpending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        name          => 'name',
        label_id      => 'label',
        edits_pending => 'editpending',
    };
}

sub _id_column
{
    return 'label_alias.id';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::LabelAlias';
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::LabelAlias - database level loading support for
label aliases.

=head1 DESCRIPTION

Provides support for loading label aliases from the database.

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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
