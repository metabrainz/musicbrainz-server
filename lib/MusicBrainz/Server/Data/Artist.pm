package MusicBrainz::Server::Data::Artist;
use Moose;

use Carp;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $VARTIST_ID $DARTIST_ID );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    defined_hash
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    partial_date_from_row
    placeholders
    query_to_list_limited
);

use Sub::Exporter -setup => {
    exports => [qw( is_special_purpose )]
};

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'artist_name' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'artist' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'artist' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_artist',
    column => 'artist',
    class => 'MusicBrainz::Server::Entity::ArtistSubscription'
};
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'artist' };

sub browse_column { 'sort_name.name' }

sub _table
{
    my $self = shift;
    return 'artist ' . (shift() || '') . ' ' .
           'JOIN artist_name name ON artist.name=name.id ' .
           'JOIN artist_name sort_name ON artist.sort_name=sort_name.id';
}

sub _table_join_name {
    my ($self, $join_on) = @_;
    return $self->_table("ON artist.name = $join_on OR artist.sort_name = $join_on");
}

sub _columns
{
    return 'artist.id, artist.gid, name.name, sort_name.name AS sort_name, ' .
           'artist.type, artist.country, gender, artist.edits_pending, artist.ipi_code, ' .
           'begin_date_year, begin_date_month, begin_date_day, ' .
           'end_date_year, end_date_month, end_date_day, artist.comment, artist.last_updated';
}

sub _id_column
{
    return 'artist.id';
}

sub _gid_redirect_table
{
    return 'artist_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sort_name',
        type_id => 'type',
        country_id => 'country',
        gender_id => 'gender',
        begin_date => sub { partial_date_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { partial_date_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        ipi_code => 'ipi_code',
        last_updated => 'last_updated',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Artist';
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_artist s ON artist.id = s.artist
                 WHERE s.editor = ?
                 ORDER BY musicbrainz_collate(name.name), artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN recording ON recording.artist_credit = acn.artist_credit
                 WHERE recording.id = ?
                 ORDER BY musicbrainz_collate(name.name), artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $recording_id, $offset || 0);
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE artist.id IN (SELECT artist.id
                     FROM artist
                     JOIN artist_credit_name acn ON acn.artist = artist.id
                     JOIN track ON track.artist_credit = acn.artist_credit
                     JOIN medium ON medium.tracklist = track.tracklist
                     WHERE medium.release = ?)
                 OR artist.id IN (SELECT artist.id
                     FROM artist
                     JOIN artist_credit_name acn ON acn.artist = artist.id
                     JOIN release ON release.artist_credit = acn.artist_credit
                     wHERE release.id = ?)
                 ORDER BY musicbrainz_collate(name.name), artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $release_id, $release_id, $offset || 0);
}

sub find_by_release_group
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN release_group ON release_group.artist_credit = acn.artist_credit
                 WHERE release_group.id = ?
                 ORDER BY musicbrainz_collate(name.name), artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $recording_id, $offset || 0);
}

sub find_by_work
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN work ON work.artist_credit = acn.artist_credit
                 WHERE work.id = ?
                 ORDER BY musicbrainz_collate(name.name), artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $recording_id, $offset || 0);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'artist', @objs);
}

sub insert
{
    my ($self, @artists) = @_;
    my %names = $self->find_or_insert_names(map { $_->{name}, $_->{sort_name} } @artists);
    my $class = $self->_entity_class;
    my @created;
    for my $artist (@artists)
    {
        my $row = $self->_hash_to_row($artist, \%names);
        $row->{gid} = $artist->{gid} || generate_gid();

        push @created, $class->new(
            name => $artist->{name},
            id => $self->sql->insert_row('artist', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @artists > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $artist_id, $update) = @_;
    croak '$artist_id must be present and > 0' unless $artist_id > 0;
    my %names = $self->find_or_insert_names($update->{name}, $update->{sort_name});
    my $row = $self->_hash_to_row($update, \%names);
    $self->sql->update_row('artist', $row, { id => $artist_id });
}

sub can_delete
{
    my ($self, $artist_id) = @_;
    return 0 if is_special_purpose($artist_id);
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

    $self->c->model('Relationship')->delete_entities('artist', @artist_ids);
    $self->annotation->delete(@artist_ids);
    $self->alias->delete_entities(@artist_ids);
    $self->tags->delete(@artist_ids);
    $self->rating->delete(@artist_ids);
    $self->remove_gid_redirects(@artist_ids);
    my $query = 'DELETE FROM artist WHERE id IN (' . placeholders(@artist_ids) . ')';
    $self->sql->do($query, @artist_ids);
    return 1;
}

sub merge
{
    my ($self, $new_id, $old_ids, %opts) = @_;

    if (grep { is_special_purpose($_) } @$old_ids) {
        confess('Attempt to merge a special purpose artist into another artist');
    }

    $self->alias->merge($new_id, @$old_ids);
    $self->tags->merge($new_id, @$old_ids);
    $self->rating->merge($new_id, @$old_ids);
    $self->subscription->merge_entities($new_id, @$old_ids);
    $self->annotation->merge($new_id, @$old_ids);
    $self->c->model('ArtistCredit')->merge_artists($new_id, $old_ids, %opts);
    $self->c->model('Edit')->merge_entities('artist', $new_id, @$old_ids);
    $self->c->model('Relationship')->merge_entities('artist', $new_id, @$old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'artist',
            columns => [ qw( comment ipi_code gender country type ) ],
            old_ids => $old_ids,
            new_id => $new_id
        )
    );

    $self->_delete_and_redirect_gids('artist', $new_id, @$old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $values, $names) = @_;

    my $row = hash_to_row($values, {
        country => 'country_id',
        type    => 'type_id',
        gender  => 'gender_id',
        comment => 'comment',
        ipi_code => 'ipi_code',
    });

    if (exists $values->{begin_date}) {
        add_partial_date_to_row($row, $values->{begin_date}, 'begin_date');
    }

    if (exists $values->{end_date}) {
        add_partial_date_to_row($row, $values->{end_date}, 'end_date');
    }

    if (exists $values->{name}) {
        $row->{name} = $names->{ $values->{name} };
    }

    if (exists $values->{sort_name}) {
        $row->{sort_name} = $names->{ $values->{sort_name} };
    }

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "artist_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating} || 0);
        $obj->rating_count($row->{rating_count} || 0);
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

    my $artists = $self->get_by_ids (keys %artist_ids);

    for my $ac (@artist_credits)
    {
        map { $_->artist ($artists->{$_->artist_id}) }
        grep { $_->artist_id } $ac->all_names;
    }
};

sub load_for_works {
    my ($self, @works) = @_;
    return unless @works;

    my %id_to_work = map { $_->id => $_ } @works;
    my @ids = keys %id_to_work;

    my $cte = '
WITH works AS (
    SELECT work.id FROM (
        VALUES ' .
            join(',', ('(?::INTEGER)') x @ids)
        . ') AS work (id)
),
work_recordings AS (
    SELECT entity0 AS recording, entity1 AS work
      FROM l_recording_work lrw
      JOIN works ON lrw.entity1 = works.id
), recordings AS (
    SELECT row_number() OVER (
               PARTITION BY work, recording
               ORDER BY count(recording_ids.recording) DESC
           ), work, recording
      FROM (
           SELECT wr.work, entity1 AS recording
             FROM l_artist_recording
             JOIN work_recordings wr ON wr.recording = entity1
        UNION ALL
           SELECT wr.work, entity1 AS recording
             FROM l_label_recording
             JOIN work_recordings wr ON wr.recording = entity1
        UNION ALL
           SELECT wr.work, entity1 AS recording
             FROM l_recording_recording
             JOIN work_recordings wr ON wr.recording = entity1
        UNION ALL
           SELECT wr.work, entity0 AS recording
             FROM l_recording_recording
             JOIN work_recordings wr ON wr.recording = entity0
        UNION ALL
           SELECT wr.work, entity0 AS recording
             FROM l_recording_release
             JOIN work_recordings wr ON wr.recording = entity0
        UNION ALL
           SELECT wr.work, entity0 AS recording
             FROM l_recording_release_group
             JOIN work_recordings wr ON wr.recording = entity0
        UNION ALL
           SELECT wr.work, entity0 AS recording
             FROM l_recording_url
             JOIN work_recordings wr ON wr.recording = entity0
        UNION ALL
           SELECT wr.work, entity0 AS recording
             FROM l_recording_work
             JOIN work_recordings wr ON wr.recording = entity0
       ) recording_ids
       GROUP BY work, recording
),
popular_recordings AS (
    SELECT work, recording FROM recordings
     WHERE row_number <= 3
)
';

    my $subq = '(
    SELECT entity1 AS work, entity0 AS artist
      FROM l_artist_work
      JOIN works ON works.id = entity1

UNION

    SELECT pr.work, acn.artist
      FROM popular_recordings pr
      JOIN recording r ON pr.recording = r.id
      JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
) s';

    my $query = $cte .
        'SELECT s.work, ' . $self->_columns .
        "  FROM $subq," . $self->_table .
        '  WHERE s.artist = artist.id';

    $self->sql->select($query, @ids);
    my %artist_cache;

    while (my $row = $self->sql->next_row_hash_ref) {
        my $artist = $artist_cache{$row->{id}} || do {
            $artist_cache{$row->{id}} = $self->_new_from_row($row);
        };

        $id_to_work{ $row->{work} }->add_artist($artist);
    }
}

sub is_special_purpose {
    my $artist_id = shift;
    return $artist_id == $VARTIST_ID || $artist_id == $DARTIST_ID;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

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
