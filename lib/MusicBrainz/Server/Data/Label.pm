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
    get_area_containment_query
    hash_to_row
    is_special_label
    load_subobjects
    merge_table_attributes
    merge_date_period
    order_by
    placeholders
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Data::Utils::Uniqueness qw( assert_uniqueness_conserved );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::IPI' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::ISNI' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_label',
    column => 'label',
    active_class => 'MusicBrainz::Server::Entity::Subscription::Label',
    deleted_class => 'MusicBrainz::Server::Entity::Subscription::DeletedLabel'
};
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Area';
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'label' }

sub _columns
{
    return 'label.id, label.gid, label.name, ' .
           'label.type, label.area, label.edits_pending, label.label_code, ' .
           'label.begin_date_year, label.begin_date_month, label.begin_date_day, ' .
           'label.end_date_year, label.end_date_month, label.end_date_day, label.ended, label.comment, label.last_updated';
}

sub _id_column
{
    return 'label.id';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
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

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_label s ON label.id = s.label
                 WHERE s.editor = ?
                 ORDER BY label.name COLLATE musicbrainz, label.id";
    $self->query_to_list_limited($query, [$editor_id], $limit, $offset);
}

sub find_by_area {
    my ($self, $area_id, $limit, $offset) = @_;
    my (
        $containment_query,
        @containment_query_args,
    ) = get_area_containment_query('$2', 'area', check_all_levels => 1);
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE area = \$1 OR EXISTS (
                    SELECT 1 FROM ($containment_query) ac
                     WHERE ac.descendant = area AND ac.parent = \$1
                 )
                 ORDER BY label.name COLLATE musicbrainz, label.id";
    $self->query_to_list_limited(
        $query, [$area_id, @containment_query_args], $limit, $offset, undef,
        dollar_placeholders => 1,
    );
}

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN release_label ON release_label.label = label.id
                 WHERE release_label.release = ?
                 ORDER BY label.name COLLATE musicbrainz";

    $self->query_to_list_limited($query, [$release_id], $limit, $offset);
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, "name", {
        "name" => sub {
            return "name COLLATE musicbrainz"
        },
        "label_code" => sub {
            return "label_code, name COLLATE musicbrainz"
        },
        "area" => sub {
            return "area, name COLLATE musicbrainz"
        },
        "begin_date" => sub {
            return "begin_date_year, begin_date_month, begin_date_day, name COLLATE musicbrainz"
        },
        "end_date" => sub {
            return "end_date_year, end_date_month, end_date_day, name COLLATE musicbrainz"
        },
        "type" => sub {
            return "type, name COLLATE musicbrainz"
        }
    });

    return $order_by
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

sub _insert_hook_after_each {
    my ($self, $created, $label) = @_;

    $self->ipi->set($created->{id}, @{ $label->{ipi_codes} });
    $self->isni->set($created->{id}, @{ $label->{isni_codes} });
}

sub update
{
    my ($self, $label_id, $update) = @_;

    my $row = $self->_hash_to_row($update);

    assert_uniqueness_conserved($self, label => $label_id, $update);

    $self->sql->update_row('label', $row, { id => $label_id }) if %$row;

    return 1;
}

sub can_delete
{
    my ($self, $label_id) = @_;
    return 0 if is_special_label($label_id);
    my $refcount = $self->sql->select_single_column_array('SELECT 1 FROM release_label WHERE label = ?', $label_id);
    return @$refcount == 0;
}

sub delete
{
    my ($self, @label_ids) = @_;
    @label_ids = grep { $self->can_delete($_) } @label_ids;

    $self->c->model('Collection')->delete_entities('label', @label_ids);
    $self->c->model('Relationship')->delete_entities('label', @label_ids);
    $self->annotation->delete(@label_ids);
    $self->alias->delete_entities(@label_ids);
    $self->ipi->delete_entities(@label_ids);
    $self->isni->delete_entities(@label_ids);
    $self->tags->delete(@label_ids);
    $self->rating->delete(@label_ids);
    $self->subscription->delete(@label_ids);
    $self->remove_gid_redirects(@label_ids);
    $self->delete_returning_gids(@label_ids);
    return 1;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    if (grep { is_special_label($_) } @old_ids) {
        confess('Attempt to merge a special purpose label into another label');
    }

    $self->alias->merge($new_id, @old_ids);
    $self->ipi->merge($new_id, @old_ids) unless is_special_label($new_id);
    $self->isni->merge($new_id, @old_ids) unless is_special_label($new_id);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('label', $new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_labels($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('label', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('label', $new_id, \@old_ids);

    unless (is_special_label($new_id)) {
        merge_table_attributes(
            $self->sql => (
                table => 'label',
                columns => [ qw( type area label_code ) ],
                old_ids => \@old_ids,
                new_id => $new_id
            )
        );

        merge_date_period(
            $self->sql => (
                table => 'label',
                old_ids => \@old_ids,
                new_id => $new_id
            )
        );
    }

    $self->_delete_and_redirect_gids('label', $new_id, @old_ids);

    return 1;
}

sub _hash_to_row
{
    my ($self, $label) = @_;
    my $row = hash_to_row($label, {
        area => 'area_id',
        type => 'type_id',
        ended => 'ended',
        map { $_ => $_ } qw( label_code comment name )
    });

    add_partial_date_to_row($row, $label->{begin_date}, 'begin_date');
    add_partial_date_to_row($row, $label->{end_date}, 'end_date');

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
    return $self->sql->select_single_value(<<~"EOSQL", $label_id, $STATUS_OPEN);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
