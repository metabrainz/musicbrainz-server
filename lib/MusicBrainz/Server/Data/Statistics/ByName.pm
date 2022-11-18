package MusicBrainz::Server::Data::Statistics::ByName;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Statistics::ByName;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistics.statistic' }

sub _columns { 'id, date_collected, name, value' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Statistics::ByName';
}

sub get_statistic {

    my ($self, $statistic) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                   FROM ' . $self->_table . '
                  WHERE name = ?';

    my @stats = @{ $self->sql->select_list_of_hashes($query, $statistic) };
    my $stats = MusicBrainz::Server::Entity::Statistics::ByName->new(
        name => $statistic,
    );

    for my $row (@stats) {
        $stats->data->{$row->{date_collected}} = $row->{value};
    }

    return $stats;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
