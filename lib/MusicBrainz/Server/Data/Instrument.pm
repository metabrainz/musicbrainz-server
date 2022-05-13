package MusicBrainz::Server::Data::Instrument;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
    merge_string_attributes
    merge_table_attributes
    order_by
);
use MusicBrainz::Server::Entity::Instrument;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'instrument' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Merge';
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Collection';

sub _type { 'instrument' }

sub _columns {
    return 'instrument.id, instrument.gid, instrument.type, instrument.name COLLATE musicbrainz,
            instrument.comment, instrument.description, instrument.edits_pending, instrument.last_updated';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        type_id => 'type',
        comment => 'comment',
        description => 'description',
        last_updated => 'last_updated',
        edits_pending => 'edits_pending',
    };
}

sub _id_column {
    return 'instrument.id';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'instrument', @objs);
}

sub update {
    my ($self, $instrument_id, $update) = @_;
    return unless %{ $update // {} };
    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('instrument', $row, { id => $instrument_id });
}

# Instruments can be removed if they're not used as relationship attributes
sub can_delete {
    my ($self, $instrument_id) = @_;
    my $refcount = $self->sql->select_single_column_array('
        SELECT 1
        FROM instrument
        JOIN link_attribute_type ON link_attribute_type.gid = instrument.gid
        JOIN link_attribute ON link_attribute.attribute_type = link_attribute_type.id
        WHERE instrument.id = ?',
        $instrument_id);
    return @$refcount == 0;
}

sub delete {
    my ($self, $instrument_id) = @_;

    $self->c->model('Collection')->delete_entities('instrument', $instrument_id);
    $self->c->model('Relationship')->delete_entities('instrument', $instrument_id);
    $self->annotation->delete($instrument_id);
    $self->alias->delete_entities($instrument_id);
    $self->tags->delete($instrument_id);
    $self->remove_gid_redirects($instrument_id);
    $self->delete_returning_gids($instrument_id);
    return;
}

after qw( insert update delete merge ) => sub {
    my ($self) = @_;
    $self->c->model('LinkAttributeType')->_delete_from_cache('all');
};

sub _merge_impl {
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Collection')->merge_entities('instrument', $new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('instrument', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('instrument', $new_id, \@old_ids);
    $self->c->model('LinkAttributeType')->merge_instrument_attributes($new_id, @old_ids);

    my @merge_options = ($self->sql => (
                           table => 'instrument',
                           old_ids => \@old_ids,
                           new_id => $new_id
                        ));

    merge_table_attributes(@merge_options, columns => [ qw( type ) ]);
    merge_string_attributes(@merge_options, columns => [ qw( description ) ]);

    $self->_delete_and_redirect_gids('instrument', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row {
    my ($self, $instrument) = @_;
    my $row = hash_to_row($instrument, {
        type => 'type_id',
        map { $_ => $_ } qw( comment name description )
    });

    return $row;
}

sub _order_by {
    my ($self, $order) = @_;
    my $order_by = order_by($order, 'name', {
        'name' => sub {
            return 'name COLLATE musicbrainz'
        },
        'type' => sub {
            return 'type, name COLLATE musicbrainz'
        }
    });

    return $order_by
}

sub get_all {
    my $self = shift;

    my $query = 'SELECT ' . $self->_columns . ' FROM ' . $self->_table;

    $self->query_to_list($query);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
