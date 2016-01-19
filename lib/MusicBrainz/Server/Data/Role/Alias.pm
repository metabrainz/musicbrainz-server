package MusicBrainz::Server::Data::Role::Alias;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Alias;
use MusicBrainz::Server::Data::Utils qw( type_to_model );
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

    requires 'c', '_entity_class';

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

        return $self->c->model(type_to_model($params->type) . 'AliasType');
    };

    around 'search_by_names' => sub {
        my ($orig, $self, @names) = @_;
        return {} unless scalar @names;

        my $type = $params->type;
        my $query =
            "WITH search (term) AS (".
            "    VALUES " . join (",", ("(?)") x scalar @names) . "), " .
            "    entity_matches (term, entity) AS (" .
            "        SELECT term, $type FROM ${type}_alias".
            "           JOIN search ON musicbrainz_unaccent(lower(${type}_alias.name)) = musicbrainz_unaccent(lower(term))" .
            "        UNION SELECT term, id FROM $type " .
            "           JOIN search ON musicbrainz_unaccent(lower(${type}.name)) = musicbrainz_unaccent(lower(term)))" .
            "      SELECT term AS search_term, ".$self->_columns.
            "      FROM ". $self->_table ." JOIN entity_matches ON entity_matches.entity = $type.id";

        my %ret;
        for my $row (@{ $self->sql->select_list_of_hashes($query, @names) }) {
            my $search_term = delete $row->{search_term};

            $ret{$search_term} ||= [];
            push @{ $ret{$search_term} }, $self->_new_from_row($row);
        }

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

