package MusicBrainz::Server::Data::Work;

use Moose;
use namespace::autoclean;
use List::AllUtils qw( uniq zip );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Entity::WorkAttribute;
use MusicBrainz::Server::Entity::WorkAttributeType;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'work' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table
{
    my $self = shift;
    return 'work';
}

sub _columns
{
    return 'work.id, work.gid, work.type, work.language,
            work.name, work.comment, work.edits_pending, work.last_updated';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        type_id => 'type',
        comment => 'comment',
        language_id => 'language',
        last_updated => 'last_updated',
        edits_pending => 'edits_pending',
    };
}

sub _id_column
{
    return 'work.id';
}

sub _gid_redirect_table
{
    return 'work_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Work';
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;

    my $query =
        'SELECT ' . $self->_columns .'
           FROM (
                    -- Select works that are related to recordings for this artist
                    SELECT entity1 AS work
                      FROM l_recording_work
                      JOIN recording ON recording.id = entity0
                      JOIN artist_credit_name acn
                              ON acn.artist_credit = recording.artist_credit
                     WHERE acn.artist = ?
              UNION
                    -- Select works that this artist is related to
                    SELECT entity1 AS work
                      FROM l_artist_work ar
                      JOIN link ON ar.link = link.id
                      JOIN link_type lt ON lt.id = link.link_type
                     WHERE entity0 = ?
                ) s, ' . $self->_table .'
          WHERE work.id = s.work
       ORDER BY musicbrainz_collate(work.name)
         OFFSET ?';

    # We actually use this for the side effect in the closure
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            $self->_new_from_row(shift);
        },
        $query, $artist_id, $artist_id, $offset || 0);
}

=method find_by_iswc

    find_by_iswc($iswc : Text)

Find works by their ISWC. Returns an array of
L<MusicBrainz::Server::Entity::Work> objects.

=cut

sub find_by_iswc
{
    my ($self, $iswc) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 JOIN iswc ON work.id = iswc.work
                 WHERE iswc.iswc = ?
                 ORDER BY musicbrainz_collate(work.name)";

    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $iswc);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'work', @objs);
}

sub insert
{
    my ($self, @works) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $work (@works)
    {
        my $row = $self->_hash_to_row($work);
        $row->{gid} = $work->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('work', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @works > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $work_id, $update) = @_;
    return unless %{ $update // {} };
    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('work', $row, { id => $work_id }) if %$row;
}

# Works can be unconditionally removed
sub can_delete { 1 }

sub delete
{
    my ($self, $work_id) = @_;
    $self->c->model('Relationship')->delete_entities('work', $work_id);
    $self->annotation->delete($work_id);
    $self->alias->delete_entities($work_id);
    $self->tags->delete($work_id);
    $self->rating->delete($work_id);
    $self->c->model('ISWC')->delete_works($work_id);
    $self->remove_gid_redirects($work_id);
    $self->sql->do('DELETE FROM work_attribute WHERE work = ?', $work_id);
    $self->sql->do('DELETE FROM work WHERE id = ?', $work_id);
    return;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('ISWC')->merge_works($new_id, @old_ids);

    $self->sql->do(
        'WITH all_attributes AS (
           DELETE FROM work_attribute WHERE work = any(?)
           RETURNING work_attribute_type, work_attribute_text,
           work_attribute_type_allowed_value
         )
         INSERT INTO work_attribute
           (work, work_attribute_type, work_attribute_text,
           work_attribute_type_allowed_value)
         SELECT DISTINCT ON
           (work_attribute_type,
            coalesce(work_attribute_text, work_attribute_type_allowed_value::text))
           ?, work_attribute_type, work_attribute_text,
           work_attribute_type_allowed_value
         FROM all_attributes',
      [ $new_id, @old_ids ], $new_id
    );

    merge_table_attributes(
        $self->sql => (
            table => 'work',
            columns => [ qw( type ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    $self->_delete_and_redirect_gids('work', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $work) = @_;
    my $row = hash_to_row($work, {
        type => 'type_id',
        language => 'language_id',
        map { $_ => $_ } qw( comment name )
    });

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "work_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
        $obj->last_updated($row->{last_updated}) if defined $row->{last_updated};
    }, @_);
}

=method load_ids

Load internal IDs for work objects that only have GIDs.

=cut

sub load_ids
{
    my ($self, @works) = @_;

    my @gids = map { $_->gid } @works;
    return () unless @gids;

    my $query = "
        SELECT gid, id FROM work
        WHERE gid IN (" . placeholders(@gids) . ")
    ";
    my %map = map { $_->[0] => $_->[1] }
        @{ $self->sql->select_list_of_lists($query, @gids) };

    for my $work (@works) {
        $work->id($map{$work->gid}) if exists $map{$work->gid};
    }
}

=method find_artists

This method will return a map with lists of artist names for the given
recordings. The names are taken both from the writers and recording artists.
This function is meant to be used to disambiguate works (e.g. in lookup
results).

=cut

sub find_artists
{
    my ($self, $works, $limit) = @_;

    my @ids = map { $_->id } @$works;
    return () unless @ids;

    my (%writers, %artists);
    $self->_find_writers(\@ids, \%writers);
    $self->_find_recording_artists(\@ids, \%artists);

    my %map = map +{
        $_ => {
            writers => { hits => 0, results => [] },
            artists => { hits => 0, results => [] }
        }
    }, @ids;

    for my $work_id (@ids) {
        my @artists = uniq map { $_->{entity}->name } @{ $artists{$work_id} };
        my @writers = uniq map { $_->{entity}->name } @{ $writers{$work_id} };

        $map{$work_id} = {
            writers => {
                hits => scalar @writers,
                results => $limit && scalar @writers > $limit
                    ? [ @writers[ 0 .. ($limit-1) ] ]
                    : \@writers,
            },
            artists => {
                hits => scalar @artists,
                results => $limit && scalar @artists > $limit
                    ? [ @artists[ 0 .. ($limit-1) ] ]
                    : \@artists,
            },
        }
    }

    return %map;
}

=method load_writers

This method will load the work's writers based on the work-artist
relationships.

=cut

sub load_writers
{
    my ($self, @works) = @_;

    @works = grep { scalar $_->all_writers == 0 } @works;
    my @ids = map { $_->id } @works;
    return () unless @ids;

    my %map;
    $self->_find_writers(\@ids, \%map);
    for my $work (@works) {
        $work->add_writer(@{ $map{$work->id} })
            if exists $map{$work->id};
    }
}

sub _find_writers
{
    my ($self, $ids, $map) = @_;
    return unless @$ids;

    my $query = "
        SELECT law.entity1 AS work, law.entity0 AS artist, array_agg(lt.name) AS roles
        FROM l_artist_work law
        JOIN link l ON law.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE law.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY law.entity1, law.entity0
        ORDER BY count(*) DESC, artist
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @artist_ids = map { $_->[1] } @$rows;
    my $artists = $self->c->model('Artist')->get_by_ids(@artist_ids);

    for my $row (@$rows) {
        my ($work_id, $artist_id, $roles) = @$row;
        $map->{$work_id} ||= [];
        push @{ $map->{$work_id} }, {
            entity => $artists->{$artist_id},
            roles => $roles
        }
    }
}

=method load_recording_artists

This method will load the work's artists based on the recordings the work
is linked to. The artist credits are sorted by the number of recordings in
descending order (i.e. the top artists will be first in the list).

=cut

sub load_recording_artists
{
    my ($self, @works) = @_;

    @works = grep { scalar $_->all_artists == 0 } @works;
    my @ids = map { $_->id } @works;
    return () unless @ids;

    my %map;
    $self->_find_recording_artists(\@ids, \%map);
    for my $work (@works) {
        $work->add_artist(map { $_->{entity} } @{ $map{$work->id} })
            if exists $map{$work->id};
    }
}

sub _find_recording_artists
{
    my ($self, $ids, $map) = @_;
    return unless @$ids;

    my $query = "
        SELECT lrw.entity1 AS work, r.artist_credit
        FROM l_recording_work lrw
        JOIN recording r ON lrw.entity0 = r.id
        WHERE lrw.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY lrw.entity1, r.artist_credit
        ORDER BY count(*) DESC, artist_credit
    ";

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @artist_credit_ids = map { $_->[1] } @$rows;
    my $artist_credits = $self->c->model('ArtistCredit')->get_by_ids(@artist_credit_ids);

    my %work_acs;
    for my $row (@$rows) {
        my ($work_id, $ac_id) = @$row;
        $work_acs{$work_id} ||= [];
        push @{ $work_acs{$work_id} }, $ac_id
    }

    for my $work_id (keys %work_acs) {
        my $artist_credit_ids = $work_acs{$work_id};
        $map->{$work_id} ||= [];
        push @{ $map->{$work_id} }, map +{
            entity => $artist_credits->{$_}
        }, @$artist_credit_ids
    }
}

sub is_empty {
    my ($self, $work_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, work => 'work_row.id');
    return $self->sql->select_single_value(<<EOSQL, $work_id, $STATUS_OPEN);
        SELECT TRUE
        FROM work work_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
          EXISTS (
            SELECT TRUE
            FROM edit_work JOIN edit ON edit_work.edit = edit.id
            WHERE status = ? AND work = work_row.id
          ) OR
          $used_in_relationship
        )
EOSQL
}

sub load_attributes {
    my ($self, @works) = @_;

    @works = grep { scalar $_->all_attributes == 0 } @works;

    my @work_ids = map { $_->id } @works;

    my $attributes = $self->sql->select_list_of_hashes(
        'SELECT
           work_attribute_type.name AS type_name,
           work_attribute_type.comment AS type_comment,
           coalesce(
             work_attribute_type_allowed_value.value,
             work_attribute.work_attribute_text
           ) AS value,
           work,
           work_attribute.work_attribute_type_allowed_value AS value_id,
           work_attribute_type.id AS type_id
         FROM work_attribute
         JOIN work_attribute_type
           ON work_attribute_type.id = work_attribute.work_attribute_type
         LEFT JOIN work_attribute_type_allowed_value
           ON work_attribute_type_allowed_value.id =
                work_attribute.work_attribute_type_allowed_value
         WHERE work_attribute.work = any(?)',
        \@work_ids
    );

    my %work_map;
    for my $work (@works) {
        push @{ $work_map{$work->id} //= [] }, $work;
    }

    for my $attribute (@$attributes) {
        for my $work (@{ $work_map{$attribute->{work}} }) {
            $work->add_attribute(
                MusicBrainz::Server::Entity::WorkAttribute->new(
                    type => MusicBrainz::Server::Entity::WorkAttributeType->new(
                        name => $attribute->{type_name},
                        comment => $attribute->{type_comment},
                        id => $attribute->{type_id}
                    ),
                    value => $attribute->{value},
                    value_id => $attribute->{value_id}
                )
            );
        }
    }
}

sub set_attributes {
    my ($self, $work_id, @attributes) = @_;
    $self->sql->do('DELETE FROM work_attribute WHERE work = ?', $work_id);
    $self->sql->insert_many(
        'work_attribute',
        map +{
            work => $work_id,
            work_attribute_type => $_->{attribute_type_id},
            work_attribute_text =>
                exists $_->{attribute_text} ?  $_->{attribute_text} : undef,
            work_attribute_type_allowed_value =>
                exists $_->{attribute_value_id} ? $_->{attribute_value_id} :
                    undef
        }, @attributes
    );
}

sub allowed_attribute_values {
    my ($self, @type_ids) = @_;
    return map {
        my ($id, $allows_free_text, $allowed_values) = @$_;
        (
            $id => {
                allows_value => do {
                    if ($allows_free_text) {
                        sub { 1 }
                    }
                    else {
                        my %allowed = map { $_ => 1 } @$allowed_values;
                        sub { exists $allowed{shift()} }
                    }
                },
                allows_free_text => $allows_free_text
            }
        )
    } @{
        $self->sql->select_list_of_lists(
            'SELECT wat.id, free_text, array_agg(watav.id) AS allowed_values
                FROM work_attribute_type wat
                LEFT JOIN work_attribute_type_allowed_value watav
                  ON (wat.id = watav.work_attribute_type)
                WHERE wat.id = any(?)
                GROUP BY wat.id',
            \@type_ids
        )
    };
}

sub all_work_attributes {
    my $self = shift;
    return map {
        my ($id, $name, $allows_free_text, $allowed_ids, $allowed_values, $comment) = @$_;
        (
            $id => {
                name => $name,
                comment => $comment,
                allowsFreeText => $allows_free_text,
                values => do {
                    if ($allows_free_text) {
                        +{};
                    }
                    else {
                        +{ zip @$allowed_ids, @$allowed_values }
                    }
                }
            }
        );
    } @{
        $self->sql->select_list_of_lists(
            'SELECT wat.id, name, free_text,
               array_agg(watav.id) AS allowed_value_ids,
               array_agg(watav.value) AS allowed_value,
               comment
             FROM work_attribute_type wat
             LEFT JOIN work_attribute_type_allowed_value watav
             ON (wat.id = watav.work_attribute_type)
             GROUP BY wat.id'
        )
    };
}

sub inflate_attributes {
    my ($self, $attributes) = @_;

    return [] unless @{ $attributes // [] };
    return [
        map {
            MusicBrainz::Server::Entity::WorkAttribute->new(
                type => MusicBrainz::Server::Entity::WorkAttributeType->new(
                    name => $_->{name},
                    comment => $_->{comment}
                ),
                value => $_->{value},
                value_id => $_->{value_id}
            )
        } @{
            $self->sql->select_list_of_hashes(
                'SELECT wat.name, wat.comment, inflate.value_id,
                   coalesce(watav.value, inflate.value_text) AS value
                 FROM
                   (VALUES ' . join(', ', ('(?::int, ?::int, ?)') x @$attributes) . ')
                     inflate (type_id, value_id, value_text)
                 JOIN work_attribute_type wat ON (wat.id = inflate.type_id)
                 LEFT JOIN work_attribute_type_allowed_value watav
                   ON (watav.work_attribute_type = wat.id AND
                       watav.id = inflate.value_id)',
                map {
                    $_->{attribute_type_id},
                    $_->{attribute_value_id},
                    $_->{attribute_text}
                } @$attributes
            );
        }
    ];
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation
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
