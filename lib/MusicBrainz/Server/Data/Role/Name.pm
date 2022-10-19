package MusicBrainz::Server::Data::Role::Name;

use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( placeholders );

requires '_columns', '_id_column', '_new_from_row', '_table';
# '_type' is indirectly required too.
requires 'c', 'query_to_list', 'sql';

sub find_by_name
{
    my ($self, $name) = @_;
    my $query = 'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
                  WHERE lower(musicbrainz_unaccent(name)) = lower(musicbrainz_unaccent(?))';
    $self->query_to_list($query, [$name]);
}

sub find_by_names
{
    my $self = shift;
    my @names = @_;

    return () unless scalar @names;

    my $query = 'SELECT ' . $self->_columns . ', search_terms.term '
        .'FROM ' . $self->_table
        . ', (VALUES '
        .     join (q(,), ('(?)') x scalar(@names))
        .    ') search_terms (term)'
        .' WHERE lower(musicbrainz_unaccent(name)) = '
        .' lower(musicbrainz_unaccent(search_terms.term));';

    my $results = $self->c->sql->select_list_of_hashes($query, @names);

    my %mapped;
    for my $row (@$results)
    {
        my $key = delete $row->{term};

        $mapped{$key} //= [];

        push @{ $mapped{$key} }, $self->_new_from_row($row);
    }

    return %mapped;
}

sub get_by_ids_sorted_by_name
{
    my ($self, @ids) = @_;
    @ids = grep { defined && $_ } @ids;
    return [] unless @ids;

    my $ordering_condition = $self->_type eq 'artist'
        ? 'sort_name COLLATE musicbrainz'
        : 'name COLLATE musicbrainz';

    my $key = $self->_id_column;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                " WHERE $key IN (" . placeholders(@ids) . ') ' .
                " ORDER BY $ordering_condition";

    my @result;
    for my $row (@{ $self->sql->select_list_of_hashes($query, @ids) }) {
        my $obj = $self->_new_from_row($row);
        push @result, $obj;
    }
    return \@result;
}

no Moose::Role;
1;

=head1 NAME

MusicBrainz::Server::Data::Role::Name

=head1 METHODS

=head2 find_by_name ($name)

Loads and returns the first instance for the specified $name.

=head2 find_by_names (@names)

Loads and returns all instances for the specified @names;
The response is an array of instantiated entities.

=head2 get_by_ids_sorted_by_name (@ids)

Loads and returns all instances for the specified @ids,
sorted by name or sorted by sort name for artist;
The response is an array of instantiated entities.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
