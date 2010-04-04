package MusicBrainz::Server::Data::URL;
use Moose;

use Carp;
use MusicBrainz::Server::Data::Utils qw( hash_to_row );
use MusicBrainz::Server::Entity::URL;
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::CoreFeyEntity';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'url' };

sub _build_table { schema->table('url') }

sub _column_mapping
{
    return {
        id              => 'id',
        gid             => 'gid',
        url             => 'url',
        description     => 'description',
        edits_pending   => 'editpending',
        reference_count => 'refcount',
    }
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::URL';
}

sub update
{
    my ($self, $url_id, $url_hash) = @_;
    croak '$url_id must be present and > 0' unless $url_id > 0;
    my $sql = Sql->new($self->c->dbh);
    my $row = $self->_hash_to_row($url_hash);
    $sql->update_row('url', $row, { id => $url_id });
}

sub _hash_to_row
{
    my ($self, $values) = @_;
    return hash_to_row($values, {
        url => 'url',
        description => 'description'
    });
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
