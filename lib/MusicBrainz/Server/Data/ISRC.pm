package MusicBrainz::Server::Data::ISRC;
use Moose;
use namespace::autoclean;

use List::AllUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::PendingEdits' => { table => 'isrc' };

sub _table
{
    return 'isrc';
}

sub _columns
{
    return 'id, isrc, recording, source, edits_pending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        isrc          => 'isrc',
        recording_id  => 'recording',
        source_id     => 'source',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ISRC';
}

sub find_by_recordings
{
    my $self = shift;

    my @ids = ref $_[0] ? @{$_[0]} : @_;
    return () unless @ids;

    my $query = 'SELECT '.$self->_columns.'
                   FROM '.$self->_table.'
                  WHERE recording IN (' . placeholders(@ids) . ')
                  ORDER BY isrc';
    $self->query_to_list($query, \@ids);
}

sub load_for_recordings
{
    my ($self, @recordings) = @_;
    my %id_to_recordings = object_to_ids(uniq @recordings);
    my @ids = keys %id_to_recordings;
    return unless @ids; # nothing to do
    my @isrcs = $self->find_by_recordings(@ids);

    $_->clear_isrcs for @recordings;

    foreach my $isrc (@isrcs) {
        foreach my $recording (@{ $id_to_recordings{$isrc->recording_id} }) {
            $recording->add_isrc($isrc);
            $isrc->recording($recording);
        }
    }
}

sub find_by_isrc
{
    my ($self, $isrc) = @_;

    my $query = 'SELECT '.$self->_columns.'
                   FROM '.$self->_table.'
                  WHERE isrc = ?
               ORDER BY id';
    $self->query_to_list($query, [$isrc]);
}

sub delete
{
    my ($self, @isrc_ids) = @_;

    # Delete ISRCs from @old_ids that already exist for $new_id
    $self->sql->do('DELETE FROM isrc
              WHERE id IN ('.placeholders(@isrc_ids).')', @isrc_ids);
}

sub merge_recordings
{
    my ($self, $new_id, @old_ids) = @_;

    my @ids = ($new_id, @old_ids);

    # Keep distinct ISRCs
    $self->sql->do(
        'DELETE FROM isrc
          WHERE recording IN ('.placeholders(@ids).')
            AND (isrc, recording) NOT IN (
                    SELECT DISTINCT ON (isrc) isrc, recording
                      FROM isrc
                     WHERE recording IN ('.placeholders(@ids).')
                )',
        @ids, @ids);

    # Move everything to the new recording
    $self->sql->do('UPDATE isrc SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')',
              $new_id, @old_ids);
}

sub delete_recordings
{
    my ($self, @ids) = @_;

    # Remove ISRCs
    $self->sql->do('DELETE FROM isrc
              WHERE recording IN ('.placeholders(@ids).')', @ids);
}

sub insert
{
    my ($self, @isrcs) = @_;

    $self->sql->do('INSERT INTO isrc (recording, isrc, source) VALUES ' .
                 (join q(,), (('(?, ?, ?)') x @isrcs)),
             map { $_->{recording_id}, $_->{isrc}, $_->{source} || undef }
                 @isrcs);
}

sub filter_additions
{
    my ($self, @additions) = @_;

    my $query =
        'SELECT DISTINCT ON (isrc, recording) array_index
           FROM (VALUES ' . join(', ', ('(?::int, ?::text, ?::int)') x @additions) . ')
                  addition (array_index, isrc, recording)
          WHERE NOT EXISTS (
                    SELECT TRUE FROM isrc
                     WHERE isrc.isrc = addition.isrc
                       AND isrc.recording = addition.recording
                           )';

    my @filtered = @{
        $self->sql->select_single_column_array(
            $query,
            do {
                my $i = 0;
                map {
                    $i++, $_->{isrc}, $_->{recording}{id}
                } @additions
            }
        )
    };
    return map { $additions[$_] } @filtered;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
