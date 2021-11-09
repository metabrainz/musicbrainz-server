package MusicBrainz::Server::Data::Recording;

use Moose;
use namespace::autoclean;
use List::AllUtils qw( nsort_by sort_by uniq uniq_by );
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
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

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

    my $query = 'SELECT DISTINCT rec.artist_credit
                 FROM recording rec
                 JOIN artist_credit_name acn
                     ON acn.artist_credit = rec.artist_credit
                 WHERE acn.artist = ?';
    my $ids = $self->sql->select_single_column_array($query, $artist_id);
    return $self->c->model('ArtistCredit')->find_by_ids($ids);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset, %args) = @_;

    my (@where_query, @where_args);

    push @where_query, 'acn.artist = ?';
    push @where_args, $artist_id;

    if (exists $args{filter}) {
        my %filter = %{ $args{filter} };
        if (exists $filter{name}) {
            push @where_query, q{(mb_simple_tsvector(recording.name) @@ plainto_tsquery('mb_simple', mb_lower(?)) OR recording.name = ?)};
            push @where_args, $filter{name}, $filter{name};
        }
        if (exists $filter{artist_credit_id}) {
            push @where_query, 'recording.artist_credit = ?';
            push @where_args, $filter{artist_credit_id};
        }
    }

    my $query = 'SELECT DISTINCT ' . $self->_columns . ',
                        recording.name COLLATE musicbrainz AS name_collate,
                        comment COLLATE musicbrainz AS comment_collate
                 FROM ' . $self->_table . '
                     JOIN artist_credit_name acn
                         ON acn.artist_credit = recording.artist_credit
                 WHERE ' . join(' AND ', @where_query) . '
                 ORDER BY recording.name COLLATE musicbrainz,
                          comment COLLATE musicbrainz';
    $self->query_to_list_limited($query, \@where_args, $limit, $offset);
}

sub find_by_artist_credit
{
    my ($self, $artist_credit_id, $limit, $offset) = @_;

    my $query = 'SELECT ' . $self->_columns . ',
                   name COLLATE musicbrainz AS name_collate
                 FROM ' . $self->_table . '
                 WHERE artist_credit = ?
                 ORDER BY name COLLATE musicbrainz';
    $self->query_to_list_limited($query, [$artist_credit_id], $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset) = @_;

    # NOTE: if more tables than l_artist_recording are added here, check admin/BuildSitemaps.pl
    my $query = 'SELECT ' . $self->_columns . q{, 
                     array_agg(json_build_object('typeName', link_type.name, 'credit', lac.credited_as)) AS instrument_credits_and_rel_types
                 FROM } . $self->_table . '
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
                 ORDER BY recording.name COLLATE musicbrainz';

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

    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                     JOIN track ON track.recording = recording.id
                     JOIN medium ON medium.id = track.medium
                     JOIN release ON release.id = medium.release
                 WHERE release.id = ?
                 ORDER BY recording.name COLLATE musicbrainz';

    $self->query_to_list_limited($query, [$release_id], $limit, $offset);
}

sub find_by_works
{
    my ($self, $work_ids, $limit, $offset) = @_;
    return ([], 0) unless @$work_ids;

    my $query = 'SELECT ' . $self->_columns . '
                 FROM '. $self->_table . '
                     JOIN l_recording_work lrw ON lrw.entity0 = recording.id
                 WHERE lrw.entity1 = any(?)
                 ORDER BY recording.name COLLATE musicbrainz';

    $self->query_to_list_limited($query, [$work_ids], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;

    my $extra_join = '';
    my $also_select = '';

    my $order_by = order_by($order, 'name', {
        'name' => sub {
            return 'name COLLATE musicbrainz'
        },
        'artist' => sub {
            $extra_join = 'JOIN artist_credit ac ON ac.id = recording.artist_credit';
            $also_select = 'ac.name AS ac_name';
            return 'ac_name COLLATE musicbrainz, recording.name COLLATE musicbrainz';
        },
        'length' => sub {
            return 'length, name COLLATE musicbrainz'
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
    MusicBrainz::Server::Data::Utils::load_meta($self->c, 'recording_meta', sub {
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
    my ($self, $recordings, $limit, $return_json) = @_;

    return {} unless scalar @$recordings;

    my @ids = map { $_->id } @$recordings;

    my $hits_query = <<~'SQL';
        SELECT rec.id AS recording, rgs.hits
        FROM recording rec, LATERAL (
            SELECT count(DISTINCT rg.id) AS hits
            FROM release_group rg
            JOIN release r ON r.release_group = rg.id
            JOIN medium m ON m.release = r.id
            JOIN track t ON t.medium = m.id
            WHERE t.recording = rec.id
        ) rgs
        WHERE rec.id = any(?)
        SQL

    my %hits_map;
    for my $row (@{ $self->sql->select_list_of_hashes($hits_query, \@ids) }) {
        $hits_map{ $row->{recording} } = $row->{hits};
    }

    my $query = <<~'SQL';
        SELECT rec.id AS recording, rgs.*
        FROM recording rec, LATERAL (
            SELECT DISTINCT rg.id, rg.gid, rg.name,
                rg.type AS primary_type_id,
                rg.artist_credit AS artist_credit_id,
                rg.edits_pending,
                rgm.first_release_date_year,
                rgm.first_release_date_month,
                rgm.first_release_date_day
            FROM release_group rg
            JOIN release_group_meta rgm ON rgm.id = rg.id
            JOIN release r ON r.release_group = rg.id
            JOIN medium m ON m.release = r.id
            JOIN track t ON t.medium = m.id
            WHERE t.recording = rec.id
            ORDER BY rgm.first_release_date_year,
                rgm.first_release_date_month,
                rgm.first_release_date_day
            LIMIT ?
        ) rgs
        WHERE rec.id = any(?)
        ORDER BY rec.id,
            rgs.first_release_date_year,
            rgs.first_release_date_month,
            rgs.first_release_date_day
        SQL

    my %map;
    for my $row (@{ $self->sql->select_list_of_hashes($query, $limit, \@ids) }) {
        my $recording_id = delete $row->{recording};
        delete $row->{first_release_date};
        push @{ $map{$recording_id} //= [] },
            MusicBrainz::Server::Data::ReleaseGroup->_new_from_row($row);
    }

    for my $rec_id (keys %map) {
        my $rgs = $map{$rec_id};

        if ($return_json) {
            $rgs = to_json_array($rgs);
        }

        $map{$rec_id} = {
            hits => $hits_map{$rec_id},
            results => $rgs,
        };
    }

    return \%map;
}

sub has_materialized_recording_first_release_date_data {
    my ($self) = @_;
    CORE::state $has_data;
    if (defined $has_data) {
        return $has_data;
    }
    $has_data = $self->sql->select_single_value(
        'SELECT 1 FROM recording_first_release_date LIMIT 1',
    ) ? 1 : 0;
    return $has_data;
}

sub load_first_release_date {
    my ($self, @recordings) = @_;

    my %recording_map = object_to_ids(@recordings);
    my @ids = keys %recording_map;
    return unless @ids;

    my $release_dates;
    if ($self->has_materialized_recording_first_release_date_data) {
        $release_dates = $self->sql->select_list_of_hashes(
            'SELECT * FROM recording_first_release_date ' .
            'WHERE recording = ANY(?)',
            [\@ids],
        );
    } else {
        $release_dates = $self->sql->select_list_of_hashes(q{
            SELECT DISTINCT ON (track.recording) track.recording,
                rd.date_year AS year,
                rd.date_month AS month,
                rd.date_day AS day
            FROM track
            JOIN medium ON medium.id = track.medium
            LEFT JOIN (
                SELECT release, date_year, date_month, date_day FROM release_country
                UNION ALL
                SELECT release, date_year, date_month, date_day FROM release_unknown_country
            ) rd ON rd.release = medium.release
            WHERE track.recording = ANY(?)
            ORDER BY track.recording,
                rd.date_year NULLS LAST,
                rd.date_month NULLS LAST,
                rd.date_day NULLS LAST
        }, [\@ids]);
    }

    my %release_date_map = map {
        $_->{recording} => PartialDate->new_from_row($_, ''),
    } @$release_dates;

    for my $id (@ids) {
        for my $recording (@{ $recording_map{$id} }) {
            my $release_date = $release_date_map{$id};
            if (defined $release_date && !$release_date->is_empty) {
                $recording->first_release_date($release_date);
            }
        }
    }
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
