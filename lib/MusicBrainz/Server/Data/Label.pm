package MusicBrainz::Server::Data::Label;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::ReleaseLabel;
use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    check_in_use
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    merge_partial_date
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'label_name' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::DeleteAndLog';
with 'MusicBrainz::Server::Data::Role::IPI' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::ISNI' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'label' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_label',
    column => 'label',
    active_class => 'MusicBrainz::Server::Entity::Subscription::Label',
    deleted_class => 'MusicBrainz::Server::Entity::Subscription::DeletedLabel'
};
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Area';

sub browse_column { 'sort_name.name' }

sub _table
{
    my $self = shift;
    return 'label ' . (shift() || '') . ' ' .
           'JOIN label_name name ON label.name=name.id ' .
           'JOIN label_name sort_name ON label.sort_name=sort_name.id';
}

sub _table_join_name {
    my ($self, $join_on) = @_;
    return $self->_table("ON label.name = $join_on OR label.sort_name = $join_on");
}

sub _columns
{
    return 'label.id, gid, name.name, sort_name.name AS sort_name, ' .
           'label.type, label.area, label.edits_pending, label.label_code, ' .
           'begin_date_year, begin_date_month, begin_date_day, ' .
           'end_date_year, end_date_month, end_date_day, ended, comment, label.last_updated';
}

sub _id_column
{
    return 'label.id';
}

sub _gid_redirect_table
{
    return 'label_gid_redirect';
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
        label_code => 'label_code',
        begin_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { MusicBrainz::Server::Entity::PartialDate->new_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        last_updated => 'last_updated',
        ended => 'ended'
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Label';
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_label s ON label.id = s.label
                 WHERE s.editor = ?
                 ORDER BY musicbrainz_collate(sort_name.name), label.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub find_by_artist
{
    my ($self, $artist_id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE label.id IN (
                         SELECT rl.label
                         FROM release_label rl
                         JOIN release ON rl.release = release.id
                         JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
                         WHERE acn.artist = ?
                 )
                 ORDER BY label.id";

    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $artist_id);
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN release_label ON release_label.label = label.id
                 WHERE release_label.release = ?
                 ORDER BY musicbrainz_collate(name.name)
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $release_id, $offset || 0);
}

sub _area_cols
{
    return ['area']
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'label', @objs);
}

sub insert
{
    my ($self, @labels) = @_;
    my %names = $self->find_or_insert_names(map { $_->{name}, $_->{sort_name } } @labels);
    my $class = $self->_entity_class;
    my @created;
    for my $label (@labels)
    {
        my $row = $self->_hash_to_row($label, \%names);
        $row->{gid} = $label->{gid} || generate_gid();

        my $created = $class->new(
            name => $label->{name},
            id => $self->sql->insert_row('label', $row, 'id'),
            gid => $row->{gid}
        );

        $self->ipi->set_ipis($created->id, @{ $label->{ipi_codes} });
        $self->isni->set_isnis($created->id, @{ $label->{isni_codes} });

        push @created, $created;
    }
    return @labels > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $label_id, $update) = @_;

    my %names = $self->find_or_insert_names($update->{name}, $update->{sort_name});
    my $row = $self->_hash_to_row($update, \%names);

    assert_uniqueness_conserved($self, label => $label_id, $update);

    $self->sql->update_row('label', $row, { id => $label_id }) if %$row;

    return 1;
}

sub in_use
{
    my ($self, $label_id) = @_;

    return check_in_use($self->sql,
        'release_label         WHERE label = ?'   => [ $label_id ],
        'l_artist_label        WHERE entity1 = ?' => [ $label_id ],
        'l_label_recording     WHERE entity0 = ?' => [ $label_id ],
        'l_label_release       WHERE entity0 = ?' => [ $label_id ],
        'l_label_release_group WHERE entity0 = ?' => [ $label_id ],
        'l_label_url           WHERE entity0 = ?' => [ $label_id ],
        'l_label_work          WHERE entity0 = ?' => [ $label_id ],
        'l_label_label         WHERE entity0 = ? OR entity1 = ?'=> [ $label_id, $label_id ],
    );
}

sub can_delete
{
    my ($self, $label_id) = @_;
    my $refcount = $self->sql->select_single_column_array('SELECT 1 FROM release_label WHERE label = ?', $label_id);
    return @$refcount == 0;
}

sub delete
{
    my ($self, @label_ids) = @_;
    @label_ids = grep { $self->can_delete($_) } @label_ids;

    $self->c->model('Relationship')->delete_entities('label', @label_ids);
    $self->annotation->delete(@label_ids);
    $self->alias->delete_entities(@label_ids);
    $self->ipi->delete_entities(@label_ids);
    $self->isni->delete_entities(@label_ids);
    $self->tags->delete(@label_ids);
    $self->rating->delete(@label_ids);
    $self->remove_gid_redirects(@label_ids);
    $self->delete_returning_gids('label', @label_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->ipi->merge($new_id, @old_ids);
    $self->isni->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->subscription->merge_entities($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_labels($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('label', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('label', $new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'label',
            columns => [ qw( type area label_code ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    merge_partial_date(
        $self->sql => (
            table => 'label',
            field => $_,
            old_ids => \@old_ids,
            new_id => $new_id
        )
    ) for qw( begin_date end_date );

    $self->_delete_and_redirect_gids('label', $new_id, @old_ids);

    return 1;
}

sub _hash_to_row
{
    my ($self, $label, $names) = @_;
    my $row = hash_to_row($label, {
        area => 'area_id',
        type => 'type_id',
        ended => 'ended',
        map { $_ => $_ } qw( label_code comment )
    });

    add_partial_date_to_row($row, $label->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $label->{end_date}, 'end_date');

    $row->{name} = $names->{$label->{name}}
        if (exists $label->{name});

    $row->{sort_name} = $names->{$label->{sort_name}}
        if (exists $label->{sort_name});

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "label_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
    }, @_);
}

sub is_empty {
    my ($self, $label_id) = @_;

    my $used_in_relationship = used_in_relationship($self->c, label => 'label_row.id');
    return $self->sql->select_single_value(<<EOSQL, $label_id, $STATUS_OPEN);
        SELECT TRUE
        FROM label label_row
        WHERE id = ?
        AND edits_pending = 0
        AND NOT (
          EXISTS (
            SELECT TRUE FROM edit_label
            WHERE status = ? AND label = label_row.id
          ) OR
          EXISTS (
            SELECT TRUE FROM release_label
            WHERE label = label_row.id
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
