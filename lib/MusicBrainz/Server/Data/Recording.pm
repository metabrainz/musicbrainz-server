package MusicBrainz::Server::Data::Recording;

use Moose;
use namespace::autoclean;
use DateTime;
use Scalar::Util qw( looks_like_number );
use Try::Tiny;
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
    hash_to_row
    merge_boolean_attributes
    merge_table_attributes
    placeholders
    load_subobjects
    order_by
);
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::ExternalUtils qw( get_chunked_with_retry );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'recording' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'recording' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'recording' }

sub _columns
{
    return 'recording.id, recording.gid, recording.name,
            recording.artist_credit AS artist_credit_id,
            recording.length, recording.comment, recording.video,
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
        video            => 'video',
        edits_pending    => 'edits_pending',
        last_updated     => 'last_updated',
    };
}

sub _id_column
{
    return 'recording.id';
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
            push @where_query, "(to_tsvector('mb_simple', recording.name) @@ plainto_tsquery('mb_simple', ?) OR recording.name = ?)";
            push @where_args, $filter{name}, $filter{name};
        }
        if (exists $filter{artist_credit_id}) {
            push @where_query, "recording.artist_credit = ?";
            push @where_args, $filter{artist_credit_id};
        }
    }

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                        musicbrainz_collate(recording.name) AS name_collate,
                        musicbrainz_collate(comment) AS comment_collate
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = recording.artist_credit
                 WHERE " . join(" AND ", @where_query) . "
                 ORDER BY musicbrainz_collate(recording.name),
                          musicbrainz_collate(comment)";
    $self->query_to_list_limited($query, \@where_args, $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset) = @_;

    # NOTE: if more tables than l_artist_recording are added here, check admin/BuildSitemaps.pl
    my $query = "SELECT " . $self->_columns . ", array_agg(lac.credited_as) AS instrument_credits
                 FROM " . $self->_table . "
                     JOIN l_artist_recording ON l_artist_recording.entity1 = recording.id
                     JOIN link_attribute ON link_attribute.link = l_artist_recording.link
                     JOIN link_attribute_type ON link_attribute_type.id = link_attribute.attribute_type
                     JOIN instrument ON instrument.gid = link_attribute_type.gid
                     LEFT JOIN link_attribute_credit lac ON (
                         lac.link = link_attribute.link AND
                         lac.attribute_type = link_attribute.attribute_type
                     )
                 WHERE instrument.id = ?
                 GROUP BY recording.id
                 ORDER BY musicbrainz_collate(recording.name)";

    $self->query_to_list_limited(
        $query,
        [$instrument_id],
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;
            my $credits = delete $row->{instrument_credits};
            { recording => $model->_new_from_row($row), instrument_credits => $credits };
        },
    );
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
                 ORDER BY musicbrainz_collate(recording.name)";

    $self->query_to_list_limited($query, [$release_id], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = "";
    my $also_select = "";

    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "musicbrainz_collate(name)"
        },
        "artist" => sub {
            $extra_join = "JOIN artist_credit ac ON ac.id = recording.artist_credit";
            $also_select = "ac.name AS ac_name";
            return "musicbrainz_collate(ac_name), musicbrainz_collate(recording.name)";
        },
        "length" => sub {
            return "length, musicbrainz_collate(name)"
        },
    });

    return ($order_by, $extra_join, $also_select)
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

sub update
{
    my ($self, $recording_id, $update) = @_;
    my $row = $self->_hash_to_row($update);
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

    $self->c->model('Collection')->delete_entities('recording', @recording_ids);
    $self->c->model('Relationship')->delete_entities('recording', @recording_ids);
    $self->c->model('ISRC')->delete_recordings(@recording_ids);
    $self->alias->delete_entities(@recording_ids);
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
    my ($self, $recording) = @_;
    my $row = hash_to_row($recording, {
        video => 'video',
        map { $_ => $_ } qw( artist_credit length comment name )
    });

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

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('ISRC')->merge_recordings($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('recording', $new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('recording', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('recording', $new_id, \@old_ids);

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

    merge_boolean_attributes(
        $self->sql => (
            table => 'recording',
            columns => [ qw( video ) ],
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
      ORDER BY musicbrainz_collate(recording.name)';
    $self->query_to_list_limited($query, [$artist_id], $limit, $offset);
}

sub find_video
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query ='
        SELECT ' . $self->_columns . '
          FROM ' . $self->_table . '
          JOIN artist_credit_name acn
            ON acn.artist_credit = recording.artist_credit
         WHERE video IS TRUE
           AND acn.artist = ?
      ORDER BY musicbrainz_collate(recording.name)';
    $self->query_to_list_limited($query, [$artist_id], $limit, $offset);
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
        "SELECT DISTINCT ON (recording.id, rg.name, type)
             rg.id, rg.gid, type AS primary_type_id, rg.name,
             rg.artist_credit AS artist_credit_id, recording.id AS recording
         FROM release_group rg
           JOIN release ON release.release_group = rg.id
           JOIN medium ON release.id = medium.release
           JOIN track ON track.medium = medium.id
           JOIN recording ON recording.id = track.recording
         WHERE recording.id IN (" . placeholders (@ids) . ")";

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        my $recording_id = delete $row->{recording};
        $map{$recording_id} ||= [];
        push @{ $map{$recording_id} }, MusicBrainz::Server::Data::ReleaseGroup->_new_from_row($row);
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

sub find_recent_by_artists
{
    my ($self, $artist_ids) = @_;

    my $search_url = sprintf("http://%s/ws/2/recording/?query=title:\"\"",
                              DBDefs->LUCENE_SERVER);

    my $ua = LWP::UserAgent->new;

    $ua->timeout(3);
    $ua->env_proxy;

    my $last_updated;

    try {
        my $response = get_chunked_with_retry($ua, $search_url);
        my $data = JSON->new->utf8->decode($response->content);

        $last_updated = DateTime::Format::ISO8601->parse_datetime($data->{created});
    }
    catch {
        $last_updated = DateTime->now;
        $last_updated->subtract( hours => 3 );
    };

    my @artist_ids = grep { looks_like_number($_) } @$artist_ids;
    return @artist_ids unless scalar @artist_ids;

    my $query = "SELECT DISTINCT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN track t ON t.recording = recording.id
                     JOIN artist_credit_name acn
                         ON (acn.artist_credit = recording.artist_credit
                         OR  acn.artist_credit = t.artist_credit)
                 WHERE acn.artist IN (" . placeholders(@artist_ids) . ")
                   AND recording.last_updated >= ?";
    $self->query_to_list($query, [@artist_ids, $last_updated->iso8601]);
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
