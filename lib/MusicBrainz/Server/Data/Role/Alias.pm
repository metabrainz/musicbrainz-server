package MusicBrainz::Server::Data::Role::Alias;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Alias;
use Moose::Util qw( ensure_all_roles );

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

parameter 'table' => (
    isa => 'Str',
    default => sub { shift->type . "_alias" },
    lazy => 1
);

role
{
    my $params = shift;

    requires 'c', '_entity_class', '_table_join_name';

    has 'alias' => (
        is => 'ro',
        builder => '_build_alias',
        lazy => 1
    );

    method '_build_alias' => sub
    {
        my $self = shift;
        my $alias = MusicBrainz::Server::Data::Alias->new(
            c      => $self->c,
            type => $params->type,
            table => $params->table,
            entity => $self->_entity_class . 'Alias',
            parent => $self
        );
        ensure_all_roles($alias, 'MusicBrainz::Server::Data::Role::Editable' => { table => $params->table });
    };

    around 'search_by_names' => sub {
        my ($orig, $self, @names) = @_;
        return {} unless scalar @names;

        my $type = $params->type;
        my $id = $self->_id_column;
        my $query =
            "WITH search (term) AS (" .
                "VALUES " . join (",", ("(?)") x scalar @names) .
            ")" .
                # Search once over aliases
                "(".
                    "SELECT search.term AS search_term, " . $self->_columns .
                    " FROM " . $self->name_table . " search_name" .
                    " JOIN search ON musicbrainz_unaccent(lower(search_name.name)) = musicbrainz_unaccent(lower(search.term))".
                    " JOIN " . $params->table . " alias ON alias.name = search_name.id" .
                    " JOIN " . $self->_table("ON alias.$type = $id")  .
                ")".
                " UNION " .
                # Search again over name/sort-name
                "(".
                    "SELECT search.term AS search_term, " . $self->_columns .
                    " FROM " . $self->name_table . " search_name" .
                    " JOIN search ON musicbrainz_unaccent(lower(search_name.name)) = musicbrainz_unaccent(lower(search.term))".
                    " JOIN " . $self->_table_join_name("search_name.id").
                ")";

        $self->c->sql->select($query, @names);
        my %ret;
        while (my $row = $self->c->sql->next_row_hash_ref) {
            my $search_term = delete $row->{search_term};

            $ret{$search_term} ||= [];
            push @{ $ret{$search_term} }, $self->_new_from_row ($row);
        }
        $self->c->sql->finish;

        return \%ret;
    };
};


no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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

