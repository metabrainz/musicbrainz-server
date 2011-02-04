package MusicBrainz::Server::Data::RecordingEchoprint;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';

with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'recording_echoprint' };

sub _table
{
    return 'recording_echoprint';
}

sub _columns
{
    return 'id, echoprint, recording, edits_pending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        echoprint_id       => 'echoprint',
        recording_id  => 'recording',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::RecordingEchoprint';
}

sub find_by_recording
{
    my $self = shift;

    my @ids = ref $_[0] ? @{$_[0]} : @_;

    my $query = "
        SELECT
            recording_echoprint.id,
            recording_echoprint.echoprint,
            recording_echoprint.recording,
            recording_echoprint.edits_pending,
            echoprint.id AS p_id,
            echoprint.echoprint AS p_echoprint,
            clientversion.version AS p_version
        FROM
            recording_echoprint
            JOIN echoprint ON echoprint.id = recording_echoprint.echoprint
            JOIN clientversion ON clientversion.id = echoprint.version
        WHERE recording_echoprint.recording IN (" . placeholders(@ids) . ")
        ORDER BY recording_echoprint.id";
    return query_to_list(
        $self->c->dbh, sub {
            $self->_create_recording_echoprint(shift);
        },
        $query, @ids);
}

sub load_for_recordings
{
    my ($self, @recordings) = @_;
    my %id_to_recordings = object_to_ids (@recordings);
    my @ids = keys %id_to_recordings;
    return unless @ids; # nothing to do
    my @echoprints = $self->find_by_recording(@ids);

    foreach my $echoprint (@echoprints) {
        foreach my $recording (@{ $id_to_recordings{$echoprint->recording_id} }) {
            $recording->add_echoprint($echoprint);
            $echoprint->recording($recording);
        }
    }
}

sub get_by_recording_echoprint
{
    my ($self, $recording_id, $echoprint_str) = @_;

    my $query = "
        SELECT
            recording_echoprint.id,
            recording_echoprint.echoprint,
            recording_echoprint.recording,
            recording_echoprint.edits_pending,
            echoprint.id AS p_id,
            echoprint.echoprint AS p_echoprint,
            clientversion.version AS p_version
        FROM
            recording_echoprint
            JOIN echoprint ON echoprint.id = recording_echoprint.echoprint
            JOIN clientversion ON clientversion.id = echoprint.version
        WHERE recording_echoprint.recording = ? AND echoprint.echoprint = ?
        ORDER BY recording_echoprint.id";

    my $sql = Sql->new($self->c->dbh);
    my $row = $sql->select_single_row_hash($query, $recording_id, $echoprint_str)
        or return;

    return $self->_create_recording_echoprint($row);
}

sub _create_recording_echoprint
{
    my ($self, $row) = @_;
    my $recording_echoprint = $self->_new_from_row($row);
    my $echoprint = $self->c->model('Echoprint')->_new_from_row($row, 'p_');
    $recording_echoprint->echoprint($echoprint);
    return $recording_echoprint;
}

sub find_by_echoprint
{
    my ($self, $echoprint_id) = @_;

    my $query = "
        SELECT
            recording_echoprint.id,
            recording_echoprint.echoprint,
            recording_echoprint.recording,
            recording_echoprint.edits_pending,
            recording.id AS r_id,
            recording.gid AS r_gid,
            name.name AS r_name,
            recording.artist_credit AS r_artist_credit_id,
            recording.length AS r_length,
            recording.comment AS r_comment,
            recording.edits_pending AS r_edits_pending
        FROM
            recording_echoprint
            JOIN recording ON recording.id = recording_echoprint.recording
            JOIN track_name name ON name.id = recording.name
        WHERE recording_echoprint.echoprint = ?
        ORDER BY name.name, recording.id";
    return query_to_list(
        $self->c->dbh, sub {
            my $row = shift;
            my $recording_echoprint = $self->_new_from_row($row);
            my $recording = $self->c->model('Recording')->_new_from_row($row, 'r_');
            $recording_echoprint->recording($recording);
            return $recording_echoprint;
        },
        $query, $echoprint_id);
}

sub merge_recordings
{
    my ($self, $new_id, @old_ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Delete links from @old_ids that already exist for $new_id
    $sql->do('DELETE FROM recording_echoprint
              WHERE recording IN ('.placeholders(@old_ids).') AND
                  echoprint IN (SELECT echoprint FROM recording_echoprint WHERE recording = ?)',
              @old_ids, $new_id);

    # Move the rest
    $sql->do('UPDATE recording_echoprint SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')',
              $new_id, @old_ids);
}

sub delete_recordings
{
    my ($self, @ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Remove Echoprint<->recording links
    my $echoprint_ids = $sql->select_single_column_array('
        DELETE FROM recording_echoprint
        WHERE recording IN ('.placeholders(@ids).')
        RETURNING echoprint', @ids);

    $self->c->model('Echoprint')->delete_unused_echoprints(@$echoprint_ids);
}

sub delete
{
    my ($self, $echoprint_id, $recording_echoprint_id) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = 'DELETE FROM recording_echoprint WHERE id = ?';
    $sql->do($query, $recording_echoprint_id);
    $self->c->model('Echoprint')->delete_unused_echoprints($echoprint_id);
}

sub filter_additions
{
    my ($self, @tuples) = @_;

    # We want to return a list of everything where either the Echoprint doesn't exist,
    # or the recording_echoprint tuple does not exist

    my @present_echoprints = values %{ $self->c->model('Echoprint')->get_by_echoprints(map { $_->{echoprint} } @tuples) };
    my %echoprints         = map { $_->echoprint => $_->id } @present_echoprints;
    my %echoprint_ids      = reverse %echoprints;

    my @additions = grep { !exists $echoprints{$_->{echoprint}}  } @tuples;
    @tuples = grep { exists $echoprints{$_->{echoprint}}  } @tuples;

    return \@additions unless @tuples;

    my $query = 'SELECT v.* FROM ' .
        '(VALUES ' . join(', ', ('(?::integer, ?::integer)') x @tuples) . ') AS v(echoprint, recording) '.
        'LEFT JOIN recording_echoprint rp ON (v.recording = rp.recording AND v.echoprint = rp.echoprint) '.
        'WHERE rp.recording IS NULL AND rp.echoprint IS NULL';

    my $rows = $self->sql->select_list_of_hashes($query, map { $echoprints{ $_->{echoprint} }, $_->{recording_id} } @tuples);
    push @additions, map +{
        echoprint         => $echoprint_ids{ $_->{echoprint} },
        recording_id => $_->{recording}
    }, @$rows;

    return \@additions;
}

sub insert
{
    my ($self, @insert) = @_;
    my $query = 'INSERT INTO recording_echoprint (echoprint, recording) VALUES ' .
        join(', ', ('(?, ?)') x @insert);
    $self->sql->do($query, map { $_->{echoprint_id}, $_->{recording_id} } @insert);
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
