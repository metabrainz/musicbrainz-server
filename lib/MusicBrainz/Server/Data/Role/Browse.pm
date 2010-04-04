package MusicBrainz::Server::Data::Role::Browse;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

use aliased 'Fey::Literal::Function';
use MusicBrainz::Server::Data::Utils qw( query_to_list_limited );

method _find_by_name_prefix_sql ($prefix, $offset)
{
    return $self->_select
        ->where(
            Function->new('page_index', $self->name_columns->{name}),
            'BETWEEN',
            Function->new('page_index',     $prefix),
            Function->new('page_index_max', $prefix),
        )
        ->order_by(Function->new('musicbrainz_collate', $self->name_columns->{name}))
        ->limit(undef, $offset);
}

method find_by_name_prefix ($prefix, $limit, $offset)
{
    my $query = $self->_find_by_name_prefix_sql($prefix, $offset);
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query->sql($self->c->dbh), $query->bind_params);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 LukasLalinsky

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

