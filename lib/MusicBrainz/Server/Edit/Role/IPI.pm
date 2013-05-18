package MusicBrainz::Server::Edit::Role::IPI;
use 5.10.0;
use Moose::Role;

with 'MusicBrainz::Server::Edit::Role::ValueSet' => {
    prop_name => 'ipi_codes',
    get_current => sub {
        my $self = shift;
        $self->c->model($self->_edit_model)
            ->ipi->find_by_entity_id($self->entity_id);
    },
    extract_value => sub { shift->ipi }
};

no Moose;
1;

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut
