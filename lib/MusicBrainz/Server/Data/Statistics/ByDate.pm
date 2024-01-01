package MusicBrainz::Server::Data::Statistics::ByDate;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Statistics::ByDate;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistics.statistic' }

sub _columns { 'id, date_collected, name, value' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Statistics::ByDate';
}

sub get_latest_statistics {

    my $self = shift;
    my $query = 'SELECT ' . $self->_columns . '
                   FROM ' . $self->_table . '
                  WHERE date_collected = (SELECT MAX(date_collected) FROM '. $self->_table .')';

    my @statistics = @{ $self->sql->select_list_of_hashes($query) }
        or return undef;

    my $stats = MusicBrainz::Server::Entity::Statistics::ByDate->new;
    for my $row (@statistics) {
        $stats->date_collected($row->{date_collected})
            unless $stats->date_collected;
        $stats->data->{$row->{name}} = $row->{value};
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
