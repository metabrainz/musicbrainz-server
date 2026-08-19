package MusicBrainz::Server::Data::Role::NoIndex;

use Moose::Role;
use namespace::autoclean;

use DBDefs;

requires '_main_table';

sub load_noindex_status {
    my ($self, @entities) = @_;

    return unless DBDefs->ACTIVE_SCHEMA_SEQUENCE == 32;

    my @ids = map { $_->id } @entities;
    return unless @ids;

    my $table = $self->_main_table;
    my $query;

    if ($table eq 'artist') {
        $query = <<~"SQL";
            SELECT $table
              FROM ${table}_noindex
             WHERE $table = any(?)
            SQL
    } elsif (
        $table eq 'recording' ||
        $table eq 'release' ||
        $table eq 'release_group'
    ) {
        $query = <<~"SQL";
            SELECT DISTINCT r.id
              FROM ${table} r
              JOIN artist_credit_name acn ON acn.artist_credit = r.artist_credit
              JOIN artist_noindex an ON an.artist = acn.artist
             WHERE r.id = any(?)
            SQL
    }

    my %noindex_ids = map { $_ => 1 } @{
        $self->c->sql->select_single_column_array($query, \@ids);
    };

    for my $entity (@entities) {
        $entity->noindex(exists $noindex_ids{ $entity->id });
    }
    return;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
