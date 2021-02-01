package MusicBrainz::Server::Data::Recording;

use Moose;
use namespace::autoclean;
use DBDefs;
use List::MoreUtils qw( uniq );
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
    object_to_ids
    order_by
);
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Entity::Recording;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'recording' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'recording' };
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
            push @where_query, "(mb_simple_tsvector(recording.name) @@ plainto_tsquery('mb_simple', mb_lower(?)) OR recording.name = ?)";
            push @where_args, $filter{name}, $filter{name};
        }
        if (exists $filter{artist_credit_id}) {
            push @where_query, "recording.artist_credit = ?";
            push @where_args, $filter{artist_credit_id};
        }
    }

    my $query = "SELECT DISTINCT " . $self->_columns . ",
                        recording.name COLLATE musicbrainz AS name_collate,
                        comment COLLATE musicbrainz AS comment_collate
                 FROM " . $self->_table . "
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = recording.artist_credit
                 WHERE " . join(" AND ", @where_query) . "
                 ORDER BY recording.name COLLATE musicbrainz,
                          comment COLLATE musicbrainz";
    $self->query_to_list_limited($query, \@where_args, $limit, $offset);
}

sub find_by_artist_credit
{
    my ($self, $artist_credit_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . ",
                   name COLLATE musicbrainz AS name_collate
                 FROM " . $self->_table . "
                 WHERE artist_credit = ?
                 ORDER BY name COLLATE musicbrainz";
    $self->query_to_list_limited($query, [$artist_credit_id], $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset) = @_;

    # NOTE: if more tables than l_artist_recording are added here, check admin/BuildSitemaps.pl
    my $query = "SELECT " . $self->_columns . ", 
                     array_agg(json_build_object('typeName', link_type.name, 'credit', lac.credited_as)) AS instrument_credits_and_rel_types
                 FROM " . $self->_table . "
                     JOIN l_artist_recording ON l_artist_recording.entity1 = recording.id
                     JOIN link ON link.id = l_artist_recording.link
                     JOIN link_type ON link_type.id = link.link_type
                     JOIN link_attribute ON link_attribute.link = link.id
                     JOIN link_attribute_type ON link_attribute_type.id = link_attribute.attribute_type
                     JOIN instrument ON instrument.gid = link_attribute_type.gid
                     LEFT JOIN link_attribute_credit lac ON (
                         lac.link = link_attribute.link AND
                         lac.attribute_type = link_attribute.attribute_type
                     )
                 WHERE instrument.id = ?
                 GROUP BY recording.id
                 ORDER BY recording.name COLLATE musicbrainz";

    $self->query_to_list_limited(
        $query,
        [$instrument_id],
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;
            my $credits_and_rel_types = delete $row->{instrument_credits_and_rel_types};
            { recording => $model->_new_from_row($row), instrument_credits_and_rel_types => $credits_and_rel_types };
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
                 ORDER BY recording.name COLLATE musicbrainz";

    $self->query_to_list_limited($query, [$release_id], $limit, $offset);
}

sub find_by_works
{
    my ($self, $work_ids, $limit, $offset) = @_;
    return ([], 0) unless @$work_ids;

    my $query = "SELECT " . $self->_columns . "
                 FROM ". $self->_table . "
                     JOIN l_recording_work lrw ON lrw.entity0 = recording.id
                 WHERE lrw.entity1 = any(?)
                 ORDER BY recording.name COLLATE musicbrainz";

    $self->query_to_list_limited($query, [$work_ids], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = "";
    my $also_select = "";

    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "name COLLATE musicbrainz"
        },
        "artist" => sub {
            $extra_join = "JOIN artist_credit ac ON ac.id = recording.artist_credit";
            $also_select = "ac.name AS ac_name";
            return "ac_name COLLATE musicbrainz, recording.name COLLATE musicbrainz";
        },
        "length" => sub {
            return "length, name COLLATE musicbrainz"
        },
    });

    my $inner_order_by = $order_by
        =~ s/ac_name/ac.name/r;

    return ($order_by, $extra_join, $also_select, $inner_order_by);
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
    $self->delete_returning_gids(@recording_ids);
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

sub has_standalone
{
    my ($self, $artist_id) = @_;
    my $query ='
        SELECT EXISTS (
            SELECT 1
            FROM recording
            JOIN artist_credit_name acn
                ON acn.artist_credit = recording.artist_credit
            WHERE acn.artist = ?
            AND NOT EXISTS (SELECT 1 FROM track WHERE track.recording = recording.id)
        )';
    $self->sql->select_single_value($query, $artist_id);
}

sub find_standalone
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query ='
        SELECT DISTINCT ' . $self->_columns . ',
            recording.name COLLATE musicbrainz
          FROM ' . $self->_table . '
     LEFT JOIN track t ON t.recording = recording.id
          JOIN artist_credit_name acn
            ON acn.artist_credit = recording.artist_credit
         WHERE t.id IS NULL
           AND acn.artist = ?
      ORDER BY recording.name COLLATE musicbrainz';
    $self->query_to_list_limited($query, [$artist_id], $limit, $offset);
}

sub has_video
{
    my ($self, $artist_id) = @_;
    my $query ='
        SELECT EXISTS (
            SELECT 1
            FROM recording
            JOIN artist_credit_name acn
                ON acn.artist_credit = recording.artist_credit
            WHERE acn.artist = ?
            AND recording.video IS TRUE
        )';
    $self->sql->select_single_value($query, $artist_id);
}

sub find_video
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query ='
        SELECT DISTINCT ' . $self->_columns . ',
            recording.name COLLATE musicbrainz
          FROM ' . $self->_table . '
          JOIN artist_credit_name acn
            ON acn.artist_credit = recording.artist_credit
         WHERE video IS TRUE
           AND acn.artist = ?
      ORDER BY recording.name COLLATE musicbrainz';
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

sub load_first_release_date {
    my ($self, @recordings) = @_;

    return unless DBDefs->ACTIVE_SCHEMA_SEQUENCE == 26;

    my %recording_map = object_to_ids(@recordings);
    my @ids = keys %recording_map;
    return unless @ids;

    my $release_dates = $self->sql->select_list_of_hashes(
        'SELECT * FROM recording_first_release_date ' .
        'WHERE recording = ANY(?)',
        [\@ids],
    );

    my %release_date_map = map {
        $_->{recording} => PartialDate->new_from_row($_, ''),
    } @$release_dates;

    for my $id (@ids) {
        for my $recording (@{ $recording_map{$id} }) {
            $recording->first_release_date($release_date_map{$id});
        }
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
