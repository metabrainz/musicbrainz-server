package MusicBrainz::Server::Data::RecordingPUID;

use Moose;
use MusicBrainz::Server::Data::Utils qw( query_to_list placeholders );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'recording_puid';
}

sub _columns
{
    return 'id, puid, recording, editpending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        puid_id       => 'puid',
        recording_id  => 'recording',
        edits_pending => 'editpending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::RecordingPUID';
}

sub find_by_recording
{
    my ($self, $recording_id) = @_;

    my $query = "
        SELECT
            recording_puid.id,
            recording_puid.puid,
            recording_puid.recording,
            recording_puid.editpending,
            puid.id AS p_id,
            puid.puid AS p_puid,
            clientversion.version AS p_version
        FROM
            recording_puid
            JOIN puid ON puid.id = recording_puid.puid
            JOIN clientversion ON clientversion.id = puid.version
        WHERE recording_puid.recording = ?
        ORDER BY recording_puid.id";
    return query_to_list(
        $self->c->dbh, sub {
            my $row = shift;
            my $recording_puid = $self->_new_from_row($row);
            my $puid = MusicBrainz::Server::Data::PUID->_new_from_row($row, 'p_');
            $recording_puid->puid($puid);
            return $recording_puid;
        },
        $query, $recording_id);
}

sub find_by_puid
{
    my ($self, $puid_id) = @_;

    my $query = "
        SELECT
            recording_puid.id,
            recording_puid.puid,
            recording_puid.recording,
            recording_puid.editpending,
            recording.id AS r_id,
            recording.gid AS r_gid,
            name.name AS r_name,
            recording.artist_credit AS r_artist_credit_id,
            recording.length AS r_length,
            recording.comment AS r_comment,
            recording.editpending AS r_edits_pending
        FROM
            recording_puid
            JOIN recording ON recording.id = recording_puid.recording
            JOIN track_name name ON name.id = recording.name
        WHERE recording_puid.puid = ?
        ORDER BY name.name, recording.id";
    return query_to_list(
        $self->c->dbh, sub {
            my $row = shift;
            my $recording_puid = $self->_new_from_row($row);
            my $recording = MusicBrainz::Server::Data::Recording->_new_from_row($row, 'r_');
            $recording_puid->recording($recording);
            return $recording_puid;
        },
        $query, $puid_id);
}

sub merge_recordings
{
    my ($self, $new_id, @old_ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Delete links from @old_ids that already exist for $new_id
    $sql->do('DELETE FROM recording_puid
              WHERE recording IN ('.placeholders(@old_ids).') AND
                  puid IN (SELECT puid FROM recording_puid WHERE recording = ?)',
              @old_ids, $new_id);

    # Move the rest
    $sql->do('UPDATE recording_puid SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')',
              $new_id, @old_ids);
}

sub delete_recordings
{
    my ($self, @ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Remove PUID<->recording links
    my $puid_ids = $sql->select_single_column_array('
        DELETE FROM recording_puid
        WHERE recording IN ('.placeholders(@ids).')
        RETURNING puid', @ids);

    # Remove unreferenced PUIDs
    if (@$puid_ids) {
        $sql->do('
            DELETE FROM puid WHERE
                id IN ('.placeholders(@$puid_ids).') AND
                id NOT IN (
                    SELECT puid FROM recording_puid
                    WHERE puid IN ('.placeholders(@$puid_ids).')
                    GROUP BY puid HAVING count(*) > 0)
            ', @$puid_ids, @$puid_ids);
    }
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
