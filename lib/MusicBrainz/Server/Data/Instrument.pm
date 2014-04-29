package MusicBrainz::Server::Data::Instrument;

use Moose;
use namespace::autoclean;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN );
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    hash_to_row
    load_subobjects
    merge_string_attributes
    merge_table_attributes
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Data::Utils::Cleanup qw( used_in_relationship );
use MusicBrainz::Server::Entity::Instrument;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Name';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'instrument' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'instrument' };
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table {
    my $self = shift;
    return 'instrument';
}

sub _columns {
    return 'instrument.id, instrument.gid, instrument.type, instrument.name,
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

sub _gid_redirect_table {
    return 'instrument_gid_redirect';
}

sub _entity_class {
    return 'MusicBrainz::Server::Entity::Instrument';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'instrument', @objs);
}

sub insert {
    my ($self, @instruments) = @_;
    my $class = $self->_entity_class;
    my @created;
    for my $instrument (@instruments) {
        my $row = $self->_hash_to_row($instrument);
        $row->{gid} = $instrument->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('instrument', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @instruments > 1 ? @created : $created[0];
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
    $self->c->model('Relationship')->delete_entities('instrument', $instrument_id);
    $self->annotation->delete($instrument_id);
    $self->alias->delete_entities($instrument_id);
    $self->remove_gid_redirects($instrument_id);
    $self->sql->do('DELETE FROM instrument WHERE id = ?', $instrument_id);
    return;
}

sub _merge_impl {
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('instrument', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('instrument', $new_id, @old_ids);
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

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
