package MusicBrainz::Server::Data::Role::Name;
use MooseX::Role::Parameterized;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );

role
{
    my $params = shift;

    requires 'c';

    method search_by_names => sub {
        my ($self, @names) = @_;
        return {} unless scalar @names;

        my $type = $params->type;
        my $query =
            "WITH search (term) AS (" .
                "VALUES " . join (",", ("(?)") x scalar @names) .
            ")" .
                # Search over name/sort-name
                "(".
                    "SELECT search.term AS search_term, " . $self->_columns .
                    " FROM " . $self->_table . " search_name" .
                    " JOIN search ON (musicbrainz_unaccent(lower(search_name.name)) = musicbrainz_unaccent(lower(search.term))" .
                ")";

        my %ret;
        for my $row (@{ $self->c->sql->select_list_of_hashes($query, @names) })
        {
            my $search_term = delete $row->{search_term};

            $ret{$search_term} ||= [];
            push @{ $ret{$search_term} }, $self->_new_from_row($row);
        }

        return \%ret;
    }
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles, 2013 MetaBrainz Foundation

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
