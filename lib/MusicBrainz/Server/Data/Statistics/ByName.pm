package MusicBrainz::Server::Data::Statistics::ByName;
use Moose;
use namespace::autoclean;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( placeholders );

use MusicBrainz::Server::Entity::Statistics::ByName;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistic' }

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

    $self->sql->select($query, $statistic) or return;

    my $stats = MusicBrainz::Server::Entity::Statistics::ByName->new();
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        $stats->name($row->{name})
            unless $stats->name;
        $stats->data->{$row->{date_collected}} = $row->{value};
    }
    $self->sql->finish;

    return $stats;
}

1;
