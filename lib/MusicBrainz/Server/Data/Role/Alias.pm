package MusicBrainz::Server::Data::Role::Alias;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Alias;
use MusicBrainz::Server::Data::AliasType;
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

    has 'alias_type' => (
        is => 'ro',
        builder => '_build_alias_type',
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

    method '_build_alias_type' => sub
    {
        my $self = shift;
        my $alias_type = MusicBrainz::Server::Data::AliasType->new(
            c      => $self->c,
            type => $params->type,
            table => $params->table . '_type',
        );
        return $alias_type;
    };

    around 'search_by_names' => sub {
        my ($orig, $self, @names) = @_;
        return {} unless scalar @names;

        my $type = $params->type;
        my $query =
            "WITH search (term) AS (".
            "    VALUES " . join (",", ("(?)") x scalar @names) . "), ";
        if ($self->has_name_table) {
            my $nametable = $self->name_table;
            $query = $query .
                "    matching_names (term, name) AS (" .
                "        SELECT term, $nametable.id FROM $nametable, search" .
                "        WHERE musicbrainz_unaccent(lower(term)) = musicbrainz_unaccent(lower($nametable.name))" .
                "    ), ".
                "    entity_matches (term, entity) AS (" .
                "        SELECT term, $type FROM ${type}_alias".
                "        JOIN matching_names ON matching_names.name = ${type}_alias.name" .
                "        UNION SELECT term, id FROM $type JOIN matching_names ON matching_names.name = $type.name " .
                "        UNION SELECT term, id FROM $type JOIN matching_names ON matching_names.name = $type.sort_name) ";
        } else {
            $query = $query .
                "    entity_matches (term, entity) AS (" .
                "        SELECT term, $type FROM ${type}_alias".
                "           JOIN search ON musicbrainz_unaccent(lower(${type}_alias.name)) = musicbrainz_unaccent(lower(term))" .
                "        UNION SELECT term, id FROM $type " .
                "           JOIN search ON musicbrainz_unaccent(lower(${type}.name)) = musicbrainz_unaccent(lower(term))" .
                "        UNION SELECT term, id FROM $type " .
                "           JOIN search ON musicbrainz_unaccent(lower(${type}.sort_name)) = musicbrainz_unaccent(lower(term))) ";
        }
        $query = $query .
            "      SELECT term AS search_term, ".$self->_columns.
            "      FROM ".$self->_table ("JOIN entity_matches ON entity_matches.entity = $type.id");

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

