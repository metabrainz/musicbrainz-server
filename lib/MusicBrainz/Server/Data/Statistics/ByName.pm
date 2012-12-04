package MusicBrainz::Server::Data::Statistics::ByName;
use Moose;
use namespace::autoclean;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( placeholders );

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
    my $query = "SELECT " . $self->_columns . "
                   FROM " . $self->_table . "
                  WHERE name = ?";

    my @stats = @{ $self->sql->select_list_of_hashes($query, $statistic) }
        or return undef;

    my $stats = MusicBrainz::Server::Entity::Statistics::ByName->new();
    for my $row (@stats) {
        $stats->name($row->{name})
            unless $stats->name;
        $stats->data->{$row->{date_collected}} = $row->{value};
    }

    return $stats;
}

1;
