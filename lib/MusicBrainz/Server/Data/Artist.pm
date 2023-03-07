package MusicBrainz::Server::Data::Artist;
use Moose;
use namespace::autoclean;

use Carp;
use List::AllUtils qw( any );
use MusicBrainz::Server::Constants qw( $ARTIST_TYPE_GROUP $STATUS_OPEN );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Utils qw(
    is_special_artist
    add_partial_date_to_row
    conditional_merge_column_query
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_date_period
    order_by
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );
use Scalar::Util qw( looks_like_number );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Relatable';
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Area';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::IPI' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::ISNI' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::GIDEntityCache';
with 'MusicBrainz::Server::Data::Role::PendingEdits' => { table => 'artist' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_artist',
    column => 'artist',
    active_class => 'MusicBrainz::Server::Entity::Subscription::Artist',
    deleted_class => 'MusicBrainz::Server::Entity::Subscription::DeletedArtist'
};
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'artist' };
with 'MusicBrainz::Server::Data::Role::Area';
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'artist' }

sub _columns
{
    return 'artist.id, artist.gid, artist.name COLLATE musicbrainz, artist.sort_name COLLATE musicbrainz, ' .
           'artist.type, artist.area, artist.begin_area, artist.end_area, ' .
           'gender, artist.edits_pending, artist.comment, artist.last_updated, ' .
           'artist.begin_date_year, artist.begin_date_month, artist.begin_date_day, ' .
           'artist.end_date_year, artist.end_date_month, artist.end_date_day,' .
           'artist.ended';
}

sub _id_column
{
    return 'artist.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sort_name',
        type_id => 'type',
        area_id => 'area',
        begin_area_id => 'begin_area',
        end_area_id => 'end_area',
        gender_id => 'gender',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        last_updated => 'last_updated',
        ended => 'ended'
    };
}

after '_delete_from_cache' => sub {
    my ($self, @ids) = @_;
    $self->c->model('ArtistCredit')->uncache_for_artist_ids(grep { looks_like_number($_) } @ids);
};

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN editor_subscribe_artist s ON artist.id = s.artist
                 WHERE s.editor = ?
                 ORDER BY artist.sort_name COLLATE musicbrainz, artist.id';
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub find_by_instrument {
    my ($self, $instrument_id, $limit, $offset) = @_;

    my $query =
        'SELECT ' . $self->_columns . q(,
                array_agg(
                    json_build_object('typeName', link_type.name, 'credit', lac.credited_as)
                    ORDER BY link_type.name, lac.credited_as, link_type.entity_type1, rels.id
                ) AS instrument_credits_and_rel_types
            FROM ) . $self->_table . '
                JOIN (
                    SELECT * FROM l_artist_artist
                    UNION ALL
                    SELECT * FROM l_artist_recording
                    UNION ALL
                    SELECT * FROM l_artist_release
                ) rels ON rels.entity0 = artist.id
                JOIN link ON link.id = rels.link
                JOIN link_type ON link_type.id = link.link_type
                JOIN link_attribute ON link_attribute.link = link.id
                JOIN link_attribute_type ON link_attribute_type.id = link_attribute.attribute_type
                JOIN instrument ON instrument.gid = link_attribute_type.gid
                LEFT JOIN link_attribute_credit lac ON (
                    lac.link = link_attribute.link AND
                    lac.attribute_type = link_attribute.attribute_type
                )
            WHERE instrument.id = ?
            GROUP BY artist.id
            ORDER BY artist.sort_name COLLATE musicbrainz';

    $self->query_to_list_limited(
        $query,
        [$instrument_id],
        $limit,
        $offset,
        sub {
            my ($model, $row) = @_;
            my $credits_and_rel_types = delete $row->{instrument_credits_and_rel_types};
            { artist => $model->_new_from_row($row), instrument_credits_and_rel_types => $credits_and_rel_types };
        },
    );
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN recording ON recording.artist_credit = acn.artist_credit
                 WHERE recording.id = ?
                 ORDER BY artist.name COLLATE musicbrainz, artist.id';
    $self->query_to_list_limited($query, [$recording_id], $limit, $offset);
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 WHERE artist.id IN (SELECT artist.id
                     FROM artist
                     JOIN artist_credit_name acn ON acn.artist = artist.id
                     JOIN track ON track.artist_credit = acn.artist_credit
                     JOIN medium ON medium.id = track.medium
                     WHERE medium.release = ?)
                 OR artist.id IN (SELECT artist.id
                     FROM artist
                     JOIN artist_credit_name acn ON acn.artist = artist.id
                     JOIN release ON release.artist_credit = acn.artist_credit
                     WHERE release.id = ?)
                 ORDER BY artist.name COLLATE musicbrainz, artist.id';
    $self->query_to_list_limited($query, [($release_id) x 2], $limit, $offset);
}

sub find_by_release_group
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN release_group ON release_group.artist_credit = acn.artist_credit
                 WHERE release_group.id = ?
                 ORDER BY artist.name COLLATE musicbrainz, artist.id';
    $self->query_to_list_limited($query, [$recording_id], $limit, $offset);
}

sub find_by_work
{
    my ($self, $work_id, $limit, $offset) = @_;
    my $query = 'SELECT DISTINCT name COLLATE musicbrainz name_collate, s.*
                 FROM (
                   SELECT ' . $self->_columns . ' FROM '. $self->_table . '
                   JOIN artist_credit_name acn ON acn.artist = artist.id
                   JOIN recording ON recording.artist_credit = acn.artist_credit
                   JOIN l_recording_work lrw ON lrw.entity0 = recording.id
                   WHERE lrw.entity1 = ?
                   UNION ALL
                   SELECT ' . $self->_columns . ' FROM '. $self->_table . '
                   JOIN l_artist_work law ON law.entity0 = artist.id
                   WHERE law.entity1 = ?
                 ) s
                 ORDER BY name COLLATE musicbrainz, id';
    $self->query_to_list_limited($query, [($work_id) x 2], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, 'name', {
        'name' => sub {
            return 'sort_name COLLATE musicbrainz'
        },
        'area' => sub {
            return 'area, name COLLATE musicbrainz'
        },
        'gender' => sub {
            return 'gender, sort_name COLLATE musicbrainz'
        },
        'begin_date' => sub {
            return 'begin_date_year, begin_date_month, begin_date_day, name COLLATE musicbrainz'
        },
        'begin_area' => sub {
            return 'begin_area, name COLLATE musicbrainz'
        },
        'end_date' => sub {
            return 'end_date_year, end_date_month, end_date_day, name COLLATE musicbrainz'
        },
        'end_area' => sub {
            return 'end_area, name COLLATE musicbrainz'
        },
        'type' => sub {
            return 'type, sort_name COLLATE musicbrainz'
        }
    });

    return $order_by
}

sub _area_columns
{
    return ['area', 'begin_area', 'end_area'];
}

sub _find_by_area_order {
    return 'sort_name, id';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'artist', @objs);
}

sub _insert_hook_after_each {
    my ($self, $created, $artist) = @_;

    $self->ipi->set($created->{id}, @{ $artist->{ipi_codes} });
    $self->isni->set($created->{id}, @{ $artist->{isni_codes} });
}

sub update
{
    my ($self, $artist_id, $update) = @_;
    croak '$artist_id must be present and > 0' unless $artist_id > 0;
    my $row = $self->_hash_to_row($update);

    assert_uniqueness_conserved($self, artist => $artist_id, $update);

    $self->sql->update_row('artist', $row, { id => $artist_id }) if %$row;
}

sub can_split
{
    my ($self, $artist_id) = @_;
    return 0 if is_special_artist($artist_id);

    # Can only split if they have no relationships at all other than collaboration
    # These AND NOT EXISTS clauses are ordered by my estimated likelihood of a 
    # relationship existing for a collaboration, as postgresql will not execute
    # the later clauses if an earlier one has already excluded the lone artist row.
    my $can_split = $self->sql->select_single_value(<<~'SQL', $artist_id);
        SELECT TRUE FROM artist WHERE id = ?
        AND NOT EXISTS (SELECT TRUE FROM l_artist_url lau WHERE lau.entity0 = artist.id)
        AND NOT EXISTS (
            SELECT TRUE FROM l_artist_artist laa
            JOIN link ON laa.link = link.id
            JOIN link_type lt ON link.link_type = lt.id
            WHERE (
                laa.entity1 = artist.id
                AND lt.gid != '75c09861-6857-4ec0-9729-84eefde7fc86' --collaboration
            )
            OR laa.entity0 = artist.id
        )
        AND NOT EXISTS (SELECT TRUE FROM l_artist_recording lar WHERE lar.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_release lare WHERE lare.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_event lae WHERE lae.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_work law WHERE law.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_label lal WHERE lal.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_place lap WHERE lap.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_release_group larg WHERE larg.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_series las WHERE las.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_artist_instrument lai WHERE lai.entity0 = artist.id)
        AND NOT EXISTS (SELECT TRUE FROM l_area_artist lara WHERE lara.entity1 = artist.id)
        SQL
    return $can_split;
}

sub can_delete
{
    my ($self, $artist_id) = @_;
    return 0 if is_special_artist($artist_id);
    my $active_credits = $self->sql->select_single_column_array(
        'SELECT ref_count FROM artist_credit, artist_credit_name name
          WHERE name.artist = ? AND name.artist_credit = id AND ref_count > 0',
        $artist_id
    );
    return @$active_credits == 0;
}

sub delete
{
    my ($self, @artist_ids) = @_;
    @artist_ids = grep { $self->can_delete($_) } @artist_ids;

    $self->c->model('Collection')->delete_entities('artist', @artist_ids);
    $self->c->model('Relationship')->delete_entities('artist', @artist_ids);
    $self->annotation->delete(@artist_ids);
    $self->alias->delete_entities(@artist_ids);
    $self->ipi->delete_entities(@artist_ids);
    $self->isni->delete_entities(@artist_ids);
    $self->tags->delete(@artist_ids);
    $self->rating->delete(@artist_ids);
    $self->subscription->delete(@artist_ids);
    $self->remove_gid_redirects(@artist_ids);
    $self->delete_returning_gids(@artist_ids);

    return 1;
}

sub merge
{
    my ($self, $new_id, $old_ids, %opts) = @_;

    if (any { is_special_artist($_) } @$old_ids) {
        confess('Attempt to merge a special purpose artist into another artist');
    }

    $self->alias->merge($new_id, @$old_ids);
    $self->ipi->merge($new_id, @$old_ids) unless is_special_artist($new_id);
    $self->isni->merge($new_id, @$old_ids) unless is_special_artist($new_id);
    $self->tags->merge($new_id, @$old_ids);
    $self->rating->merge($new_id, @$old_ids);
    $self->annotation->merge($new_id, @$old_ids);
    $self->c->model('ArtistCredit')->merge_artists($new_id, $old_ids, %opts);
    $self->c->model('Edit')->merge_entities('artist', $new_id, @$old_ids);
    $self->c->model('Collection')->merge_entities('artist', $new_id, @$old_ids);
    $self->c->model('Relationship')->merge_entities('artist', $new_id, $old_ids, rename_credits => $opts{rename});

    # We detect cases where a merged artist type or gender is dropped due to
    # it conflicting with a type or gender on the target or elsewhere (since
    # only persons can have a gender). In Edit::Artist::Merge, we use the
    # result of %dropped_columns to inform users of what information was
    # dropped. This is done as opposed to failing the edit outright, since
    # that's arguably more annoying for the editor. See MBS-10187.
    my %dropped_columns;
    unless (is_special_artist($new_id)) {
        my $merge_columns = [ qw( area begin_area end_area ) ];
        my $target_row = $self->sql->select_single_row_hash('SELECT gender, type FROM artist WHERE id = ?', $new_id);
        my $target_type = $target_row->{type};
        my $target_gender = $target_row->{gender};
        my $merged_type = $target_type;
        my $merged_gender = $target_gender;

        if (!$merged_type) {
            my ($query, $args) = conditional_merge_column_query(
                'artist', 'type', $new_id, [$new_id, @$old_ids], 'IS NOT NULL');
            $merged_type = $self->c->sql->select_single_value($query, @$args);
        }

        if (!$merged_gender) {
            my ($query, $args) = conditional_merge_column_query(
                'artist', 'gender', $new_id, [$new_id, @$old_ids], 'IS NOT NULL');
            $merged_gender = $self->c->sql->select_single_value($query, @$args);
        }

        my $group_types = $self->sql->select_single_column_array(q{
            WITH RECURSIVE atp(id) AS (
                VALUES (?::int)
                 UNION
                SELECT artist_type.id
                  FROM artist_type
                  JOIN atp ON atp.id = artist_type.parent
            ) SELECT * FROM atp
        }, $ARTIST_TYPE_GROUP);

        my $merged_type_is_group =
            defined $merged_type &&
            any { $merged_type eq $_ } @$group_types;

        if ($merged_type_is_group && $merged_gender) {
            my $target_type_is_group =
                defined $target_type &&
                any { $target_type eq $_ } @$group_types;

            if ($target_type_is_group) {
                $dropped_columns{gender} = $merged_gender;
                push @$merge_columns, 'type';
            } elsif ($target_gender) {
                $dropped_columns{type} = $merged_type;
                push @$merge_columns, 'gender';
            } else {
                $dropped_columns{gender} = $merged_gender;
                $dropped_columns{type} = $merged_type;
            }
        } else {
            push @$merge_columns, qw( gender type );
        }

        merge_table_attributes(
            $self->sql => (
                table => 'artist',
                columns => $merge_columns,
                old_ids => $old_ids,
                new_id => $new_id
            )
        );

        merge_date_period(
            $self->sql => (
                table => 'artist',
                old_ids => $old_ids,
                new_id => $new_id
            )
        );
    }

    $self->_delete_and_redirect_gids('artist', $new_id, @$old_ids);
    return (1, \%dropped_columns);
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    my $row = hash_to_row($values, {
        area => 'area_id',
        begin_area => 'begin_area_id',
        end_area => 'end_area_id',
        type    => 'type_id',
        gender  => 'gender_id',
        comment => 'comment',
        ended => 'ended',
        name => 'name',
        sort_name => 'sort_name',
    });

    if (exists $values->{begin_date}) {
        add_partial_date_to_row($row, $values->{begin_date}, 'begin_date');
    }

    if (exists $values->{end_date}) {
        add_partial_date_to_row($row, $values->{end_date}, 'end_date');
    }

    return $row;
}

sub load_related_info {
    my ($self, @artists) = @_;

    my $c = $self->c;
    $c->model('ArtistType')->load(@artists);
    $c->model('Gender')->load(@artists);
    $c->model('Area')->load(@artists);
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, 'artist_meta', sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
    }, @_);
}


sub load_for_artist_credits {
    my ($self, @artist_credits) = @_;

    return unless @artist_credits;

    my %artist_ids;
    for my $ac (@artist_credits)
    {
        map { $artist_ids{$_->artist_id} = 1 }
        grep { $_->artist_id } $ac->all_names;
    }

    my $artists = $self->get_by_ids(keys %artist_ids);

    for my $ac (@artist_credits)
    {
        map { $_->artist($artists->{$_->artist_id}) }
        grep { $_->artist_id } $ac->all_names;
    }
};

sub is_empty {
    my ($self, $artist_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, artist => 'artist_row.id');
    return $self->sql->select_single_value(<<~"SQL", $artist_id, $STATUS_OPEN);
        SELECT TRUE
        FROM artist artist_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
            EXISTS (
                SELECT TRUE FROM edit_artist
                WHERE status = ? AND artist = artist_row.id
            ) OR
            EXISTS (
                SELECT TRUE FROM artist_credit_name
                WHERE artist = artist_row.id
                LIMIT 1
            ) OR
            $used_in_relationship
        )
        SQL
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
