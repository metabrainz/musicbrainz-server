package MusicBrainz::Server::Report;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Sql';
with 'MusicBrainz::Server::Data::Role::QueryToList';

use String::CamelCase qw( decamelize );

requires 'run';

sub qualified_table {
    my $self = shift;
    return join('.', 'report', $self->table);
}

sub table {
    my $self = shift;
    my $name = $self->meta->name;
    $name =~ s/MusicBrainz::Server::Report::(.*)$/$1/;
    return decamelize($name);
}

sub load {
    my ($self, $c, $limit, $offset) = @_;

    $self->_load($c, '', $limit, $offset);
}

sub _load {
    my ($self, $c, $join_sql, $limit, $offset, @params) = @_;

    my $qualified_table = $self->qualified_table;
    my $ordering = $self->ordering;

    my ($rows, $hits) = $self->query_to_list_limited(
        "SELECT DISTINCT report.* FROM $qualified_table report $join_sql ORDER BY $ordering",
        \@params,
        $limit,
        $offset,
        sub { $_[1] },
    );

    ($self->inflate_rows($rows, $c), $hits);
}

sub ordering { "row_number" }

sub inflate_rows {
    my ($self, $rows) = @_;
    return $rows;
}

sub generated {
    my ($self) = @_;
    return $self->sql->select_single_value(
        'SELECT TRUE FROM information_schema.tables WHERE table_schema = ? AND table_name = ?',
        'report', $self->table
    );
}

sub generated_at {
    my ($self) = @_;
    my $timestamp = $self->sql->select_single_value(
        'SELECT generated_at FROM report.index WHERE report_name = ?',
        $self->table
    );
    if ($timestamp) {
        $timestamp = DateTime::Format::Pg->parse_datetime($timestamp);
    }
    return $timestamp;
}

sub component_name {}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
