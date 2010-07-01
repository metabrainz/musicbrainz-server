package MusicBrainz::Server::Data::ISRC;

use Moose;
use MusicBrainz::Server::Data::Utils qw( query_to_list placeholders );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'isrc';
}

sub _columns
{
    return 'id, isrc, recording, source, editpending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        isrc          => 'isrc',
        recording_id  => 'recording',
        source_id     => 'source',
        edits_pending => 'editpending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ISRC';
}

sub find_by_recording
{
    my ($self, $ids) = @_;

    my @ids = ref $ids ? @$ids : ( $ids );
    my $query = "SELECT ".$self->_columns."
                   FROM ".$self->_table."
                  WHERE recording IN (" . placeholders(@ids) . ")
                  ORDER BY isrc";
    return query_to_list($self->c->dbh, sub { $self->_new_from_row($_[0]) },
                         $query, @ids);
}

sub find_by_isrc
{
    my ($self, $isrc) = @_;

    my $query = "SELECT ".$self->_columns."
                   FROM ".$self->_table."
                  WHERE isrc = ?
               ORDER BY id";
    return query_to_list($self->c->dbh, sub { $self->_new_from_row($_[0]) },
                         $query, $isrc);
}

sub delete
{
    my ($self, @isrc_ids) = @_;
    my $sql = Sql->new($self->c->dbh);

    # Delete ISRCs from @old_ids that already exist for $new_id
    $sql->do('DELETE FROM isrc
              WHERE id IN ('.placeholders(@isrc_ids).')', @isrc_ids);
}

sub merge_recordings
{
    my ($self, $new_id, @old_ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Delete ISRCs from @old_ids that already exist for $new_id
    $sql->do('DELETE FROM isrc
              WHERE recording IN ('.placeholders(@old_ids).') AND
                  isrc IN (SELECT isrc FROM isrc WHERE recording = ?)',
              @old_ids, $new_id);

    # Move the rest
    $sql->do('UPDATE isrc SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')',
              $new_id, @old_ids);
}

sub delete_recordings
{
    my ($self, @ids) = @_;

    my $sql = Sql->new($self->c->dbh);

    # Remove ISRCs
    $sql->do('DELETE FROM isrc
              WHERE recording IN ('.placeholders(@ids).')', @ids);
}

sub insert
{
    my ($self, @isrcs) = @_;
    my $sql = Sql->new($self->c->dbh);

    $sql->do('INSERT INTO isrc (recording, isrc, source) VALUES ' .
                 (join ",", (("(?, ?, ?)") x @isrcs)),
             map { $_->{recording_id}, $_->{isrc}, $_->{source} || undef }
                 @isrcs);
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
