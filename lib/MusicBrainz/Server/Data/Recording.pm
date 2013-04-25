package MusicBrainz::Server::Data::Recording;

use Moose;
use namespace::autoclean;
use List::UtilsBy qw( rev_nsort_by sort_by uniq_by );
use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_CREATE
    $EDIT_HISTORIC_ADD_TRACK
    $EDIT_HISTORIC_ADD_TRACK_KV
);
use MusicBrainz::Server::Data::Track;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    hash_to_row
    merge_table_attributes
    placeholders
    load_subobjects
    query_to_list_limited
);
use MusicBrainz::Server::Entity::Recording;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'recording' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'track_name' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'recording' };
with 'MusicBrainz::Server::Data::Role::BrowseVA';
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table
{
    return 'recording JOIN track_name name ON recording.name=name.id';
}

sub _columns
{
    return 'recording.id, recording.gid, name.name,
            recording.artist_credit AS artist_credit_id,
            recording.length, recording.comment,
            recording.edits_pending, recording.last_updated';
}
sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        name             => 'name',
        artist_credit_id => 'artist_credit_id',
        length           => 'length',
        comment          => 'comment',
        edits_pending    => 'edits_pending',
        last_updated     => 'last_updated',
    };
}

sub _id_column
{
    return 'recording.id';
}

sub _gid_redirect_table
{
    return 'recording_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Recording';
}

sub find_artist_credits_by_artist
{
    my ($self, $artist_id) = @_;

    my $query = "SELECT DISTINCT rec.artist_credit
                 FROM recording rec
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rec.artist_credit
                 WHERE acn.artist = ?";
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->c->model('ArtistCredit')->find_by_ids($ids);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my (@where_query, @where_args);
   
    push @where_query, "acn.artist = ?";
    push @where_args, $artist_id;

    if (exists $args{filter}) {
        my %filter = %{ $args{filter} };
        if (exists $filter{name}) {
            push @where_query, "(to_tsvector('mb_simple', name.name) @@ plainto_tsquery('mb_simple', ?) OR name.name = ?)";
            push @where_args, $filter{name}, $filter{name};
        }
        if (exists $filter{artist_credit_id}) {
            push @where_query, "recording.artist_credit = ?";
            push @where_args, $filter{artist_credit_id};
        }
    }

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                        musicbrainz_collate(name.name) AS name_collate,
                        musicbrainz_collate(comment) AS comment_collate
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = recording.artist_credit
                 WHERE " . join(" AND ", @where_query) . "
                 ORDER BY musicbrainz_collate(name.name),
                          musicbrainz_collate(comment)
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, @where_args, $offset || 0);
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN track ON track.recording = recording.id
                     JOIN medium ON medium.id = track.medium
                     JOIN release ON release.id = medium.release
                 WHERE release.id = ?
                 ORDER BY musicbrainz_collate(name.name)
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $release_id, $offset || 0);
}

sub can_delete {
    my ($self, $recording_id) = @_;
    return !$self->sql->select_single_value(
        'SELECT 1 FROM track WHERE recording = ? LIMIT 1',
        $recording_id
    );
}

sub load
{
    my ($self, @objs) = @_;
    return load_subobjects($self, 'recording', @objs);
}

sub insert
{
    my ($self, @recordings) = @_;
    my $track_data = MusicBrainz::Server::Data::Track->new(c => $self->c);
    my %names = $track_data->find_or_insert_names(map { $_->{name} } @recordings);
    my $class = $self->_entity_class;
    my @created;
    for my $recording (@recordings)
    {
        my $row = $self->_hash_to_row($recording, \%names);
        $row->{gid} = $recording->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('recording', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @recordings > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $recording_id, $update) = @_;
    my $track_data = MusicBrainz::Server::Data::Track->new(c => $self->c);
    my %names = $track_data->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $self->sql->update_row('recording', $row, { id => $recording_id });
}

sub usage_count
{
    my ($self, $recording_id) = @_;
    return $self->sql->select_single_value(
        'SELECT count(*) FROM track
          WHERE recording = ?', $recording_id);
}

sub delete
{
    my ($self, @recording_ids) = @_;

    $self->c->model('Relationship')->delete_entities('recording', @recording_ids);
    $self->c->model('RecordingPUID')->delete_recordings(@recording_ids);
    $self->c->model('ISRC')->delete_recordings(@recording_ids);
    $self->annotation->delete(@recording_ids);
    $self->tags->delete(@recording_ids);
    $self->rating->delete(@recording_ids);
    $self->remove_gid_redirects(@recording_ids);
    $self->sql->do(
        'DELETE FROM recording WHERE id IN (' . placeholders(@recording_ids) . ')',
        @recording_ids
    );
    return;
}

sub _hash_to_row
{
    my ($self, $recording, $names) = @_;
    my $row = hash_to_row($recording, {
        map { $_ => $_ } qw( artist_credit length comment )
    });

    $row->{name} = $names->{$recording->{name}}
        if (exists $recording->{name});

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "recording_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
    }, @_);
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('RecordingPUID')->merge_recordings($new_id, @old_ids);
    $self->c->model('ISRC')->merge_recordings($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('recording', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('recording', $new_id, @old_ids);

    # Move tracks to the new recording
    $self->sql->do('UPDATE track SET recording = ?
              WHERE recording IN ('.placeholders(@old_ids).')', $new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'recording',
            columns => [ qw( length ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    $self->_delete_and_redirect_gids('recording', $new_id, @old_ids);
    return 1;
}

sub find_standalone
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query ='
        SELECT ' . $self->_columns . '
          FROM ' . $self->_table . '
     LEFT JOIN track t ON t.recording = recording.id
          JOIN artist_credit_name acn
            ON acn.artist_credit = recording.artist_credit
         WHERE t.id IS NULL
           AND acn.artist = ?
      ORDER BY musicbrainz_collate(name.name)
        OFFSET ?';
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $artist_id, $offset || 0);
}

=method appears_on

This method will return a list of release groups the recordings appear
on. The results are ordered using the type-id (so albums come first,
then singles, etc..) and then by name.

=cut

sub appears_on
{
    my ($self, $recordings, $limit) = @_;

    return () unless scalar @$recordings;

    my @ids = map { $_->id } @$recordings;

    my $query =
        "SELECT DISTINCT ON (recording.id, name.name, type)
             rg.id, rg.gid, type AS primary_type_id, name.name,
             rg.artist_credit AS artist_credit_id, recording.id AS recording
         FROM release_group rg
           JOIN release_name name ON rg.name=name.id
           JOIN release ON release.release_group = rg.id
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
           JOIN recording ON recording.id = track.recording
         WHERE recording.id IN (" . placeholders (@ids) . ")";

    my %map;
    $self->sql->select ($query, @ids);

    while (my $row = $self->sql->next_row_hash_ref) {
        my $recording_id = delete $row->{recording};
        $map{$recording_id} ||= [];
        push @{ $map{$recording_id} }, MusicBrainz::Server::Data::ReleaseGroup->_new_from_row ($row);
    }

    for my $rec_id (keys %map)
    {
        # A crude ordering of importance.
        my @rgs = uniq_by { $_->name }
                  rev_nsort_by { $_->primary_type_id // -1 }
                  sort_by { $_->name  }
                  @{ $map{$rec_id} };

        $map{$rec_id} = {
            hits => scalar @rgs,
            results => scalar @rgs > $limit ? [ @rgs[ 0 .. ($limit-1) ] ] : \@rgs,
        }
    }

    return %map;
}

=method find_tracklist_offsets

Attempt to find all absolute offsets of when a recording appears in a releases
tracklist, over all its mediums. For example, if a recording is the 3rd track
on the first medium, it's offset is 2. If it's the first track on the 2nd medium
and the first medium contains 10 tracks, it's 10.

The return value is a list of (release_id, offset) tuples.

=cut

sub find_tracklist_offsets {
    my ($self, $recording_id) = @_;

    # This query attempts to find all offsets of a recording on various
    # releases. It does so by:
    #
    # 1. `bef` CTE:
    #   a. Select all mediums that a recording appears on.
    #   b. Select all mediums on the same release that are *before*
    #      the mediums found in (a).
    #   c. Group by the containing medium (a).
    #   d. Sum the total track count of all prior mediums (b).
    # 2. Main query:
    #   a. Find all tracks with this recording_id.
    #   b. Find the corresponding `bef` count.
    #   c. Add `bef` count to the track position, and subtract on for /ws/1
    #      compat.
    my $offsets = $self->sql->select_list_of_lists(<<'EOSQL', $recording_id);
    WITH
      r (id) AS ( SELECT ?::int ),
      bef AS (
        SELECT container.id AS container,
               sum(container.track_count)
        FROM medium container
        JOIN track ON track.medium = container.id
        JOIN medium bef ON (
          container.release = bef.release AND
          container.position > bef.position
        )
        JOIN r ON r.id = track.recording
        GROUP BY container.id, track.id
      )
      SELECT medium.release, (track.position - 1) + COALESCE(bef.sum, 0)
      FROM track
      JOIN r ON r.id = track.recording
      JOIN medium ON track.medium = medium.id
      LEFT JOIN bef ON bef.container = medium.id;
EOSQL

    return $offsets;
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
