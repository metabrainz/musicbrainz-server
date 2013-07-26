package MusicBrainz::Server::Data::RecordingPUID;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';

with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'recording_puid' };

sub _table
{
    return 'recording_puid';
}

sub _columns
{
    return 'id, puid, recording, edits_pending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        puid_id       => 'puid',
        recording_id  => 'recording',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::RecordingPUID';
}

sub find_by_recording
{
    my $self = shift;

    my @ids = ref $_[0] ? @{$_[0]} : @_;
    return () unless @ids;

    my $query = "
        SELECT
            recording_puid.id,
            recording_puid.puid,
            recording_puid.recording,
            recording_puid.edits_pending,
            puid.id AS p_id,
            puid.puid AS p_puid,
            clientversion.version AS p_version
        FROM
            recording_puid
            JOIN puid ON puid.id = recording_puid.puid
            JOIN clientversion ON clientversion.id = puid.version
        WHERE recording_puid.recording IN (" . placeholders(@ids) . ")
        ORDER BY recording_puid.id";
    return query_to_list(
        $self->c->sql, sub {
            $self->_create_recording_puid(shift);
        },
        $query, @ids);
}

sub load_for_recordings
{
    my ($self, @recordings) = @_;
    my %id_to_recordings = object_to_ids (uniq @recordings);
    my @ids = keys %id_to_recordings;
    return unless @ids; # nothing to do
    my @puids = $self->find_by_recording(@ids);

    foreach my $puid (@puids) {
        foreach my $recording (@{ $id_to_recordings{$puid->recording_id} }) {
            $recording->add_puid($puid);
            $puid->recording($recording);
        }
    }
}

sub get_by_recording_puid
{
    my ($self, $recording_id, $puid_str) = @_;

    my $query = "
        SELECT
            recording_puid.id,
            recording_puid.puid,
            recording_puid.recording,
            recording_puid.edits_pending,
            puid.id AS p_id,
            puid.puid AS p_puid,
            clientversion.version AS p_version
        FROM
            recording_puid
            JOIN puid ON puid.id = recording_puid.puid
            JOIN clientversion ON clientversion.id = puid.version
        WHERE recording_puid.recording = ? AND puid.puid = ?
        ORDER BY recording_puid.id";

    my $row = $self->sql->select_single_row_hash($query, $recording_id, $puid_str)
        or return;

    return $self->_create_recording_puid($row);
}

sub _create_recording_puid
{
    my ($self, $row) = @_;
    my $recording_puid = $self->_new_from_row($row);
    my $puid = $self->c->model('PUID')->_new_from_row($row, 'p_');
    $recording_puid->puid($puid);
    return $recording_puid;
}

sub find_by_puid
{
    my ($self, $puid_id) = @_;

    my $query = "
        SELECT
            recording_puid.id,
            recording_puid.puid,
            recording_puid.recording,
            recording_puid.edits_pending,
            recording.id AS r_id,
            recording.gid AS r_gid,
            recording.name AS r_name,
            recording.artist_credit AS r_artist_credit_id,
            recording.length AS r_length,
            recording.comment AS r_comment,
            recording.edits_pending AS r_edits_pending
        FROM
            recording_puid
            JOIN recording ON recording.id = recording_puid.recording
        WHERE recording_puid.puid = ?
        ORDER BY recording.name, recording.id";
    return query_to_list(
        $self->c->sql, sub {
            my $row = shift;
            my $recording_puid = $self->_new_from_row($row);
            my $recording = $self->c->model('Recording')->_new_from_row($row, 'r_');
            $recording_puid->recording($recording);
            return $recording_puid;
        },
        $query, $puid_id);
}

sub merge_recordings
{
    my ($self, $new_id, @old_ids) = @_;

    my @ids = ($new_id, @old_ids);

    # Delete links from @old_ids that already exist for $new_id
    $self->sql->do('DELETE FROM recording_puid
              WHERE recording IN ('.placeholders(@ids).')
                AND id NOT IN (
                SELECT DISTINCT ON (puid) id
                  FROM recording_puid
                 WHERE recording IN ('.placeholders(@ids).')
              )', @ids, @ids);

    # Move the rest
    $self->sql->do('UPDATE recording_puid SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')',
              $new_id, @old_ids);
}

sub delete_recordings
{
    my ($self, @ids) = @_;

    # Remove PUID<->recording links
    my $puid_ids = $self->sql->select_single_column_array('
        DELETE FROM recording_puid
        WHERE recording IN ('.placeholders(@ids).')
        RETURNING puid', @ids);

    $self->c->model('PUID')->delete_unused_puids(@$puid_ids);
}

sub delete
{
    my ($self, $puid_id, $recording_puid_id) = @_;
    my $query = 'DELETE FROM recording_puid WHERE id = ?';
    $self->sql->do($query, $recording_puid_id);
    $self->c->model('PUID')->delete_unused_puids($puid_id);
}

sub filter_additions
{
    my ($self, @tuples) = @_;

    # We want to return a list of everything where either the PUID doesn't exist,
    # or the recording_puid tuple does not exist

    my @present_puids = values %{ $self->c->model('PUID')->get_by_puids(map { $_->{puid} } @tuples) };
    my %puids         = map { $_->puid => $_->id } @present_puids;
    my %puid_ids      = reverse %puids;

    my @additions = grep { !exists $puids{$_->{puid}}  } @tuples;
    @tuples = grep { exists $puids{$_->{puid}}  } @tuples;

    return \@additions unless @tuples;

    my $query = 'SELECT DISTINCT ON (v.puid, v.recording) v.* FROM
        (VALUES ' . join(', ', ('(?::integer, ?::integer, ?)') x @tuples) . ') AS v(puid, recording, name)
        LEFT JOIN recording_puid rp ON (v.recording = rp.recording AND v.puid = rp.puid)
        WHERE rp.recording IS NULL AND rp.puid IS NULL';

    my $rows = $self->sql->select_list_of_hashes(
        $query,
        map { $puids{ $_->{puid} }, $_->{recording}{id}, $_->{recording}{name} } @tuples
    );
    push @additions, map +{
        puid         => $puid_ids{ $_->{puid} },
        recording    => {
            id   => $_->{recording},
            name => $_->{name}
        }
    }, @$rows;

    return \@additions;
}

sub insert
{
    my ($self, @insert) = @_;
    my $query = 'INSERT INTO recording_puid (puid, recording) VALUES ' .
        join(', ', ('(?, ?)') x @insert);
    $self->sql->do($query, map { $_->{puid_id}, $_->{recording_id} } @insert);
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
