package MusicBrainz::Server::Data::Role::Alias;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use MusicBrainz::Server::Data::Alias;
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use Moose::Util qw( ensure_all_roles );

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

parameter 'table' => (
    isa => 'Str',
    default => sub { shift->type . '_alias' },
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
        ensure_all_roles($alias, 'MusicBrainz::Server::Data::Role::PendingEdits' => { table => $params->table });
    };

    method '_build_alias_type' => sub
    {
        my $self = shift;

        return $self->c->model(type_to_model($params->type) . 'AliasType');
    };

    method 'search_by_names' => sub {
        my ($self, @names) = @_;
        return {} unless scalar @names;

        my $type = $params->type;
        my $query =
            'WITH search (term) AS ('.
            '    VALUES ' . join (q(,), ('(?)') x scalar @names) . '), ' .
            '    entity_matches (term, entity) AS (' .
            "        SELECT term, $type FROM ${type}_alias".
            "           JOIN search ON lower(musicbrainz_unaccent(${type}_alias.name)) = lower(musicbrainz_unaccent(term))" .
            "        UNION SELECT term, id FROM $type " .
            "           JOIN search ON lower(musicbrainz_unaccent(${type}.name)) = lower(musicbrainz_unaccent(term)))" .
            '      SELECT term AS search_term, '.$self->_columns.
            '      FROM '. $self->_table ." JOIN entity_matches ON entity_matches.entity = $type.id";

        my %ret;
        for my $row (@{ $self->sql->select_list_of_hashes($query, @names) }) {
            my $search_term = delete $row->{search_term};

            $ret{$search_term} ||= [];
            push @{ $ret{$search_term} }, $self->_new_from_row($row);
        }

        return \%ret;
    };
};


1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

