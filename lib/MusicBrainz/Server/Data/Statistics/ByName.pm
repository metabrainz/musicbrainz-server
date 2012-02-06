package MusicBrainz::Server::Data::Statistics::ByName;
use Moose;
use namespace::autoclean;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( placeholders );

use MusicBrainz::Server::Entity::Statistics::ByName;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistic' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Statistics::ByName';
}

sub get_statistic {

    my ($self, $statistic) = @_;
    my $query = "SELECT id,
                        date_collected,
                        name,
                        value
                   FROM statistic
                  WHERE name = '$statistic'";

    $self->sql->select($query) or return;

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

sub get_statistics {
    my ($self, @statistics) = @_;
    my $query = "SELECT id,
                        date_collected,
			name,
			value
                   FROM statistic
		  WHERE name IN (" . placeholders(@statistics) . ")";
    $self->sql->select($query, @statistics) or return;

    my $return = {};
    foreach my $statistic (@statistics) {
        $return->{$statistic} = MusicBrainz::Server::Entity::Statistics::ByName->new();
    }
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
	my $obj = $return->{$row->{name}};
	$obj->name($row->{name}) unless $obj->name;
	$obj->data->{$row->{date_collected}} = $row->{value};
    }
    $self->sql->finish;

    return $return;
}


1;
