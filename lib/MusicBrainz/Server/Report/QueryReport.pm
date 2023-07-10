package MusicBrainz::Server::Report::QueryReport;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report';

requires 'query';

sub run {
    my ($self) = @_;

    my $qualified_table = $self->qualified_table;
    my $query = $self->query;

    if ($self->can('statement_timeout')) {
        $self->sql->do(
            'SET LOCAL statement_timeout = ?',
            $self->statement_timeout,
        );
    }
    $self->sql->do("DROP TABLE IF EXISTS $qualified_table");
    $self->sql->do(
        "SELECT s.*
         INTO $qualified_table
         FROM ( $query ) s"
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

