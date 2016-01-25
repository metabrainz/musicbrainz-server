package MusicBrainz::Server::Data::Artist;
use Moose;
use namespace::autoclean;

use Carp;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $VARTIST_ID $DARTIST_ID $STATUS_OPEN );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Utils qw(
    is_special_artist
    add_partial_date_to_row
    defined_hash
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_date_period
    order_by
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );
use Scalar::Util qw( looks_like_number );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::DeleteAndLog';
with 'MusicBrainz::Server::Data::Role::IPI' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::ISNI' => { type => 'artist' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'artist' };
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
    return 'artist.id, artist.gid, artist.name, artist.sort_name, ' .
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
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_artist s ON artist.id = s.artist
                 WHERE s.editor = ?
                 ORDER BY musicbrainz_collate(artist.sort_name), artist.id";
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    LEFT JOIN area ON artist.area = area.id
                    LEFT JOIN area begin_area ON artist.begin_area = begin_area.id
                    LEFT JOIN area end_area ON artist.end_area = end_area.id
                 WHERE ? IN (area.id, begin_area.id, end_area.id)
                 ORDER BY musicbrainz_collate(artist.name), artist.id";
    $self->query_to_list_limited($query, [$area_id], $limit, $offset);
}

sub find_by_recording
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN recording ON recording.artist_credit = acn.artist_credit
                 WHERE recording.id = ?
                 ORDER BY musicbrainz_collate(artist.name), artist.id";
    $self->query_to_list_limited($query, [$recording_id], $limit, $offset);
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
                     JOIN medium ON medium.id = track.medium
                     WHERE medium.release = ?)
                 OR artist.id IN (SELECT artist.id
                     FROM artist
                     JOIN artist_credit_name acn ON acn.artist = artist.id
                     JOIN release ON release.artist_credit = acn.artist_credit
                     wHERE release.id = ?)
                 ORDER BY musicbrainz_collate(artist.name), artist.id";
    $self->query_to_list_limited($query, [($release_id) x 2], $limit, $offset);
}

sub find_by_release_group
{
    my ($self, $recording_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN artist_credit_name acn ON acn.artist = artist.id
                    JOIN release_group ON release_group.artist_credit = acn.artist_credit
                 WHERE release_group.id = ?
                 ORDER BY musicbrainz_collate(artist.name), artist.id";
    $self->query_to_list_limited($query, [$recording_id], $limit, $offset);
}

sub find_by_work
{
    my ($self, $work_id, $limit, $offset) = @_;
    my $query = "SELECT DISTINCT musicbrainz_collate(name) name_collate, s.*
                 FROM (
                   SELECT " . $self->_columns . " FROM ". $self->_table . "
                   JOIN artist_credit_name acn ON acn.artist = artist.id
                   JOIN recording ON recording.artist_credit = acn.artist_credit
                   JOIN l_recording_work lrw ON lrw.entity0 = recording.id
                   WHERE lrw.entity1 = ?
                   UNION ALL
                   SELECT " . $self->_columns . " FROM ". $self->_table . "
                   JOIN l_artist_work law ON law.entity0 = artist.id
                   WHERE law.entity1 = ?
                 ) s
                 ORDER BY musicbrainz_collate(name), id";
    $self->query_to_list_limited($query, [($work_id) x 2], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "musicbrainz_collate(name)"
        },
        "gender" => sub {
            return "gender, musicbrainz_collate(name)"
        },
        "type" => sub {
            return "type, musicbrainz_collate(name)"
        }
    });

    return $order_by
}

sub _area_cols
{
    return ['area', 'begin_area', 'end_area'];
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'artist', @objs);
}

sub _insert_hook_after_each {
    my ($self, $created, $artist) = @_;

    $self->ipi->set_ipis($created->{id}, @{ $artist->{ipi_codes} });
    $self->isni->set_isnis($created->{id}, @{ $artist->{isni_codes} });
}

sub update
{
    my ($self, $artist_id, $update) = @_;
    croak '$artist_id must be present and > 0' unless $artist_id > 0;
    my $row = $self->_hash_to_row($update);

    assert_uniqueness_conserved($self, artist => $artist_id, $update);

    $self->sql->update_row('artist', $row, { id => $artist_id }) if %$row;
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
    $self->delete_returning_gids('artist', @artist_ids);

    return 1;
}

sub merge
{
    my ($self, $new_id, $old_ids, %opts) = @_;

    if (grep { is_special_artist($_) } @$old_ids) {
        confess('Attempt to merge a special purpose artist into another artist');
    }

    $self->alias->merge($new_id, @$old_ids);
    $self->ipi->merge($new_id, @$old_ids) unless is_special_artist($new_id);
    $self->isni->merge($new_id, @$old_ids) unless is_special_artist($new_id);
    $self->tags->merge($new_id, @$old_ids);
    $self->rating->merge($new_id, @$old_ids);
    $self->subscription->merge_entities($new_id, @$old_ids);
    $self->annotation->merge($new_id, @$old_ids);
    $self->c->model('ArtistCredit')->merge_artists($new_id, $old_ids, %opts);
    $self->c->model('Edit')->merge_entities('artist', $new_id, @$old_ids);
    $self->c->model('Collection')->merge_entities('artist', $new_id, @$old_ids);
    $self->c->model('Relationship')->merge_entities('artist', $new_id, $old_ids, rename_credits => $opts{rename});

    unless (is_special_artist($new_id)) {
        my $merge_columns = [ qw( area begin_area end_area type ) ];
        my $artist_type = $self->sql->select_single_value('SELECT type FROM artist WHERE id = ?', $new_id);
        my $group_type = 2;
        my $orchestra_type = 5;
        my $choir_type = 6;
        if ($artist_type != $group_type && $artist_type != $orchestra_type && $artist_type != $choir_type) {
            push @$merge_columns, 'gender';
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
    return 1;
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

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "artist_meta", sub {
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
    return $self->sql->select_single_value(<<EOSQL, $artist_id, $STATUS_OPEN);
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
EOSQL
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
