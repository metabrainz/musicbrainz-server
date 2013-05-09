package MusicBrainz::Server::Data::Role::Name;
use MooseX::Role::Parameterized;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );

parameter 'name_table' => (
    isa => 'Maybe[Str]',
    required => 0,
    predicate => 'has_name_table'
);

role
{
    my $params = shift;
    my $table = $params->has_name_table ? $params->name_table : undef;

    requires 'c';

    has 'name_table' => (
        isa => 'Maybe[Str]',
        is => 'ro',
        default => $table,
        predicate => 'has_name_table'
    );

    method 'find_or_insert_names' => sub
    {
        my ($self, @names) = @_;
        if (!$self->has_name_table) {
            warn "Called find_or_insert_names for an entity type not using a name table";
            return undef;
        }
        @names = uniq grep { defined } @names or return;
        my $query = "SELECT id, name FROM $table" .
                    ' WHERE name IN (' . placeholders(@names) . ')';
        my $found = $self->sql->select_list_of_hashes($query, @names);
        my %found_names = map { $_->{name} => $_->{id} } @$found;
        for my $new_name (grep { !exists $found_names{$_} } @names)
        {
            my $id = $self->sql->insert_row($table, {
                    name => $new_name,
                }, 'id');
            $found_names{$new_name} = $id;
        }
        return %found_names;
    };

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
                    " FROM " . ( $self->name_table // $self->_table ) . " search_name" .
                    " JOIN search ON (musicbrainz_unaccent(lower(search_name.name)) = musicbrainz_unaccent(lower(search.term))".
                    ($self->has_name_table ?
                     ") JOIN " . $self->_table_join_name("search_name.id") :
                     " OR musicbrainz_unaccent(lower(search_name.sort_name)) = musicbrainz_unaccent(lower(search.term)))").
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
