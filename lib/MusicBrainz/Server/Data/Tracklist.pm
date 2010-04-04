package MusicBrainz::Server::Data::Tracklist;

use Moose;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Subobject';

sub _build_table { schema->table('tracklist') }

sub _table
{
    return 'tracklist';
}

sub _columns
{
    return 'id, trackcount AS track_count';
}

sub _column_mapping
{
    return {
        id          => 'id',
        track_count => 'trackcount',
    }
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Tracklist';
}

sub offset_track_positions
{
    my ($self, $tracklist_id, $start_position, $offset) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = 'UPDATE track SET position = position + ?' .
                ' WHERE position >= ? AND tracklist = ?';
    $sql->do($query, $offset, $start_position, $tracklist_id);
}

sub insert
{
    my ($self, $tracks) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $id = $sql->insert_row('tracklist', { trackcount => 0 }, 'id');
    my @tracks = @$tracks;
    $_->{tracklist} = $id for @tracks;
    $self->c->model('Track')->insert(@tracks);
    my $class = $self->_entity_class;
    return $class->new( id => $id );
}

sub delete
{
    my ($self, @tracklist_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = 'DELETE FROM track WHERE tracklist IN (' . placeholders(@tracklist_ids). ')';
    $sql->do($query, @tracklist_ids);
    $query = 'DELETE FROM tracklist WHERE id IN ('. placeholders(@tracklist_ids) . ')';
    $sql->do($query, @tracklist_ids);
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
