package MusicBrainz::Server::Edit::Historic::Utils;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw(
        upgrade_date
        upgrade_id
        upgrade_type
    )]
};

use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );

sub upgrade_date
{
    my $date = shift;
    $date =~ s/^\s+//;
    $date =~ s/\s+$//;
    return partial_date_to_hash($date ? PartialDate->new($date) : PartialDate->new());
}

sub upgrade_id
{
    my $id = shift;
    return !$id || $id == 0 ? undef : $id;
}

my %type_map = (
    album => 'release',
    track => 'recording'
);

sub upgrade_type
{
    my $type = shift;
    return $type_map{$type} || $type;
}

1;
