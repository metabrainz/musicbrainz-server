package MusicBrainz::Server::Data::Tracklist;

use Moose;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Data::Utils qw( load_subobjects placeholders );
use MusicBrainz::Server::Log qw( log_assertion );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'tracklist';
}

sub _columns
{
    return 'id, track_count';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Tracklist';
}

sub insert
{
    my ($self, $tracks) = @_;
    # track_count is 0 because the trigger will increment it
    my $id = $self->sql->insert_row('tracklist', { track_count => 0 }, 'id');
    $self->_add_tracks($id, $tracks);
    $self->c->model('DurationLookup')->update($id);
    my $class = $self->_entity_class;
    return $class->new( id => $id );
}

sub delete
{
    my ($self, @tracklist_ids) = @_;
    my $query = 'DELETE FROM track WHERE tracklist IN (' . placeholders(@tracklist_ids). ')';
    $self->sql->do($query, @tracklist_ids);
    $query = 'DELETE FROM tracklist WHERE id IN ('. placeholders(@tracklist_ids) . ')';
    $self->sql->do($query, @tracklist_ids);
}

sub replace
{
    my ($self, $tracklist_id, $tracks) = @_;

    my $new_tracklist = $self->find_or_insert($tracks);
    return unless ($new_tracklist->id != $tracklist_id);

    $self->sql->do('UPDATE medium SET tracklist = ? WHERE tracklist = ?',
                   $new_tracklist->id, $tracklist_id);

    # XXX Should go through Tracklist->delete
    my @possibly_orphaned_recordings = @{
        $self->sql->select_single_column_array(
            'DELETE FROM track WHERE tracklist = ? RETURNING recording', $tracklist_id
        )
    };
    $self->sql->do('DELETE FROM tracklist WHERE id = ?', $tracklist_id);
    $self->c->model('Recording')->garbage_collect_orphans(@possibly_orphaned_recordings);

    return $new_tracklist->id;
}

sub _add_tracks {
    my ($self, $id, $tracks) = @_;
    my $i = 1;
    $self->c->model('Track')->insert(
        map +{
            recording_id  => $_->{recording_id},
            tracklist     => $id,
            position      => $i++,
            name          => $_->{name},
            artist_credit => $self->c->model('ArtistCredit')->find_or_insert($_->{artist_credit}),
            length        => $_->{length},
        }, @$tracks);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'tracklist', @objs);
}

sub usage_count
{
    my ($self, $tracklist_id) = @_;
    $self->sql->select_single_value(
        'SELECT count(*) FROM medium
           JOIN tracklist ON medium.tracklist = tracklist.id
          WHERE tracklist.id = ?', $tracklist_id);
}

sub garbage_collect {
    my $self = shift;

    my @orphaned_tracklists = @{
        $self->sql->select_single_column_array(
            'SELECT tracklist.id FROM tracklist
          LEFT JOIN medium ON medium.tracklist = tracklist.id
              WHERE medium.id IS NULL'
        )
    };

    if (@orphaned_tracklists) {
        my @possibly_orphaned_recordings = @{
            $self->sql->select_single_column_array(
                'DELETE FROM track
                 WHERE tracklist IN ('. placeholders(@orphaned_tracklists) . ')
                 RETURNING recording',
                @orphaned_tracklists
            )
        };

        $self->c->model('Recording')->garbage_collect_orphans(@possibly_orphaned_recordings);

        $self->sql->do(
            'DELETE FROM tracklist
              WHERE id IN ('. placeholders(@orphaned_tracklists) . ')',
            @orphaned_tracklists);
    }
}

sub set_lengths_to_cdtoc
{
    my ($self, $tracklist_id, $cdtoc_id) = @_;
    my $cdtoc = $self->c->model('CDTOC')->get_by_id($cdtoc_id)
        or die "Could not load CDTOC";

    my $tracklist = $self->c->model('Tracklist')->get_by_id($tracklist_id)
        or die "Could not load tracklist";

    $self->c->model('Track')->load_for_tracklists($tracklist);
    $self->c->model('ArtistCredit')->load($tracklist->all_tracks);

    my @info = @{ $cdtoc->track_details };
    for my $i (0..$#info) {
        $tracklist->tracks->[$i]->length($info[$i]->{length_time});
        $i++;
    }

    $tracklist_id = $self->replace($tracklist_id, $tracklist->tracks);
    $self->c->model('DurationLookup')->update($tracklist_id);
}

sub merge
{
    my ($self, $new_tracklist_id, $old_tracklist_id) = @_;
    my @recording_merges = @{
        $self->sql->select_list_of_lists(
            'SELECT DISTINCT newt.recording AS new, oldt.recording AS old
               FROM track oldt
               JOIN track newt ON newt.position = oldt.position
              WHERE newt.tracklist = ? AND oldt.tracklist = ?
                AND newt.recording != oldt.recording',
            $new_tracklist_id, $old_tracklist_id
        )
    };

    # We need to make sure that for each old recording, there is only 1 new recording
    # to merge into. If there is > 1, then it's not clear what we should merge into.
    my %target_count;
    $target_count{ $_->[1] }++ for @recording_merges;

    for my $recording_merge (@recording_merges) {
        my ($new, $old) = @$recording_merge;
        next if $target_count{$old} > 1;

        $self->c->model('Recording')->merge(@$recording_merge);
    }
}

sub find
{
    my ($self, $tracks) = @_;

    my $query =
        'SELECT tracklist
           FROM (
                    SELECT tracklist FROM track
                      JOIN track_name name ON name.id = track.name
                     WHERE ' . join(' OR ', ('(
                               name.name ILIKE ?
                           AND artist_credit = ?
                           AND position = ?
                           )') x @$tracks) . '
                ) s
       GROUP BY tracklist
         HAVING COUNT(tracklist) = ?';

    return @{
        $self->sql->select_single_column_array(
            $query,
            (map {
                $_->{name},
                $self->c->model('ArtistCredit')->find_or_insert($_->{artist_credit}),
                $_->{position}
            } @$tracks),
            scalar(@$tracks)
        )
    };
}

sub find_or_insert
{
    my ($self, $tracks) = @_;
    my $query =
        'SELECT tracklist
           FROM (
                    SELECT tracklist, count(track.id) AS matched_track_count
                      FROM track
                      JOIN track_name name ON name.id = track.name
                     WHERE ' . join(' OR ',map {
                         '(' . join(' AND ',
                                    'name.name = ?',
                                    'artist_credit = ?',
                                    'recording = ?',
                                    defined($_->{length}) ? 'length = ?' : 'length IS NULL',
                                    'position = ?') .
                         ')' } @$tracks) . '
                  GROUP BY tracklist
                ) s
           JOIN tracklist ON s.tracklist = tracklist.id
          WHERE tracklist.track_count = s.matched_track_count
            AND tracklist.track_count = ?';

    my $i = 1;
    my @possible_tracklists = @{
        $self->sql->select_single_column_array(
            $query,
            (map {
                $_->{name},
                $self->c->model('ArtistCredit')->find_or_insert($_->{artist_credit}),
                $_->{recording_id},
                defined($_->{length}) ? $_->{length} : (),
                $i++,
            } @$tracks),
            scalar(@$tracks)
        )
    };

    if (@possible_tracklists) {
        log_assertion { @possible_tracklists == 1 }
            'Only finds a single matching tracklist';

        return $self->_entity_class->new(
            id => $possible_tracklists[0]
        );
    }
    else {
        $self->insert($tracks);
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
