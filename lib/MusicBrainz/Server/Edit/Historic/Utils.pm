package MusicBrainz::Server::Edit::Historic::Utils;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw(
        upgrade_date
        upgrade_id
    )]
};

use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );

sub upgrade_date
{
    my $date = shift;
    return partial_date_to_hash($date ? PartialDate->new($date) : PartialDate->new());
}

sub upgrade_id
{
    my $id = shift;
    return !$id || $id == 0 ? undef : $id;
}

1;
