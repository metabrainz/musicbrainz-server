package MusicBrainz::Server::Data::Role::Name;
use MooseX::Role::Parameterized;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );

parameter 'name_table' => (
    isa => 'Str',
    required => 1,
);

role
{
    my $params = shift;
    my $table = $params->name_table;

    requires 'c';

    has 'name_table' => (
        isa => 'Str',
        is => 'ro',
        default => $table
    );

    method 'find_or_insert_names' => sub
    {
        my ($self, @names) = @_;
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
