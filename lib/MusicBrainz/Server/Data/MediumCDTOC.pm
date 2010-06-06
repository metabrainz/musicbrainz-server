package MusicBrainz::Server::Data::MediumCDTOC;
use Moose;
use Method::Signatures::Simple;

use MusicBrainz::Server::Data::Utils qw( query_to_list );
use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

method _build_table  { schema->table('medium_cdtoc') }
method _entity_class { 'MusicBrainz::Server::Entity::MediumCDTOC' }

method _column_mapping
{
    return {
        id            => 'id',
        medium_id     => 'medium',
        cdtoc_id      => 'cdtoc',
        edits_pending => 'editpending',
    };
}

method find_by_medium(@medium_ids)
{
    my $query = $self->_select
        ->where($self->table->column('medium'), 'IN', @medium_ids)
        ->order_by($self->table->column('id'));

    return query_to_list(
        $self->c->dbh, sub { $self->_new_from_row(@_) },
        $query->sql($self->c->dbh), $query->bind_params);
}

method load_for_mediums (@mediums)
{
    my %id_to_medium = map { $_->id => $_ } @mediums;
    my @list = $self->find_by_medium(keys %id_to_medium);
    foreach my $o (@list) {
        $id_to_medium{$o->medium_id}->add_cdtoc($o);
    }
    return @list;
}

method find_by_cdtoc ($cdtoc_id)
{
    return sort { $a->id <=> $b->id }
        values %{ $self->_get_by_keys("cdtoc", $cdtoc_id) };
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
