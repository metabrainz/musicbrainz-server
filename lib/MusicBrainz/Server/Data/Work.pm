package MusicBrainz::Server::Data::Work;

use Moose;
use namespace::autoclean;
use List::AllUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
    merge_table_attributes
    order_by
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Entity::WorkAttribute;
use MusicBrainz::Server::Entity::WorkAttributeType;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Collection';
with 'MusicBrainz::Server::Data::Role::ValueSet' => {
    entity_type         => 'work',
    plural_value_type   => 'languages',
    value_attribute     => 'language_id',
    value_class         => 'WorkLanguage',
    value_type          => 'language',
};

sub _type { 'work' }

sub _columns
{
    return 'work.id, work.gid, work.type,
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
        last_updated => 'last_updated',
        edits_pending => 'edits_pending',
    };
}

sub _id_column
{
    return 'work.id';
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
       ORDER BY work.name COLLATE musicbrainz';

    # We actually use this for the side effect in the closure
    $self->query_to_list_limited($query, [($artist_id) x 2], $limit, $offset);
}

=method find_by_iswc

    find_by_iswc($iswc : Text)

Find works by their ISWC. Returns an array of
L<MusicBrainz::Server::Entity::Work> objects.

=cut

sub find_by_iswc
{
    my ($self, $iswc) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 JOIN iswc ON work.id = iswc.work
                 WHERE iswc.iswc = ?
                 ORDER BY work.name COLLATE musicbrainz';

    $self->query_to_list($query, [$iswc]);
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, 'name', {
        'name' => sub {
            return 'name COLLATE musicbrainz'
        },
        'type' => sub {
            return 'type, name COLLATE musicbrainz'
        },
    });

    return $order_by;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'work', @objs);
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

sub delete {
    my ($self, $work_id) = @_;

    $self->c->model('Collection')->delete_entities('work', $work_id);
    $self->c->model('Relationship')->delete_entities('work', $work_id);
    $self->annotation->delete($work_id);
    $self->alias->delete_entities($work_id);
    $self->language->delete_entities($work_id);
    $self->tags->delete($work_id);
    $self->rating->delete($work_id);
    $self->c->model('ISWC')->delete_works($work_id);
    $self->remove_gid_redirects($work_id);
    $self->sql->do('DELETE FROM work_attribute WHERE work = ?', $work_id);
    $self->delete_returning_gids($work_id);
    return;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->language->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('work', $new_id, \@old_ids);
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
        map { $_ => $_ } qw( comment name )
    });

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, 'work_meta', sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
        $obj->last_updated($row->{last_updated}) if defined $row->{last_updated};
    }, @_);
}

sub load_related_info {
    my ($self, @works) = @_;

    my $c = $self->c;
    $c->model('Work')->load_writers(@works);
    $c->model('Work')->load_recording_artists(@works);
    $c->model('WorkAttribute')->load_for_works(@works);
    $c->model('ISWC')->load_for_works(@works);
    $c->model('WorkType')->load(@works);
    $c->model('Language')->load_for_works(@works);
}

=method load_ids

Load internal IDs for work objects that only have GIDs.

=cut

sub load_ids
{
    my ($self, @works) = @_;

    my @gids = map { $_->gid } @works;
    return () unless @gids;

    my $query = '
        SELECT gid, id FROM work
        WHERE gid IN (' . placeholders(@gids) . ')
    ';
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

    my %map;

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
        };
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

    @works = grep { defined $_ && scalar $_->all_writers == 0 } @works;
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

    my $query = '
        SELECT law.entity1 AS work, law.entity0 AS artist, 
            law.entity0_credit AS credit, array_agg(lt.name) AS roles
        FROM l_artist_work law
        JOIN link l ON law.link = l.id
        JOIN link_type lt ON l.link_type = lt.id
        WHERE law.entity1 IN (' . placeholders(@$ids) . ')
        GROUP BY law.entity1, law.entity0, law.entity0_credit
        ORDER BY count(*) DESC, artist, credit
    ';

    my $rows = $self->sql->select_list_of_lists($query, @$ids);

    my @artist_ids = map { $_->[1] } @$rows;
    my $artists = $self->c->model('Artist')->get_by_ids(@artist_ids);

    for my $row (@$rows) {
        my ($work_id, $artist_id, $credit, $roles) = @$row;
        $map->{$work_id} ||= [];
        push @{ $map->{$work_id} }, {
            credit => $credit,
            entity => $artists->{$artist_id},
            roles => [ uniq @{ $roles } ]
        }
    }
}

=method load_recording_artists

This method will load the work's artists based on the recordings the work
is linked to. The artist credits are sorted by the number of tracks for
the recordings by that artist in descending order. This ensures the 
artists most associated with the work will be listed first.

=cut

sub load_recording_artists
{
    my ($self, @works) = @_;

    @works = grep { defined $_ && scalar $_->all_artists == 0 } @works;
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

    my $query = '
        SELECT lrw.entity1 AS work, r.artist_credit
        FROM l_recording_work lrw
        JOIN recording r ON lrw.entity0 = r.id
        LEFT JOIN track t ON r.id = t.recording
        WHERE lrw.entity1 IN (' . placeholders(@$ids) . ')
        GROUP BY lrw.entity1, r.artist_credit
        ORDER BY count(*) DESC, artist_credit
    ';

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
    return $self->sql->select_single_value(<<~"SQL", $work_id, $STATUS_OPEN);
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
        SQL
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

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
