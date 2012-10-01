package MusicBrainz::Server::Data::Statistics::ByDate;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Statistics::ByDate;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistic' }

sub _columns { 'id, date_collected, name, value' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Statistics::ByDate';
}

sub get_latest_statistics {

    my $self = shift;
    my $query = "SELECT " . $self->_columns . "
                   FROM " . $self->_table . "
                  WHERE date_collected = (SELECT MAX(date_collected) FROM ". $self->_table .")";

    $self->sql->select($query) or return;

    my $stats = MusicBrainz::Server::Entity::Statistics::ByDate->new();
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        $stats->date_collected($row->{date_collected})
            unless $stats->date_collected;
        $stats->data->{$row->{name}} = $row->{value};
    }
    $self->sql->finish;

    return $stats;
}

1;
