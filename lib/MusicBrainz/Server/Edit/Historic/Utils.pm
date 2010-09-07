package MusicBrainz::Server::Edit::Historic::Utils;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw(
        upgrade_date
        upgrade_id
        upgrade_type
        upgrade_release_type
        upgrade_release_status
        upgrade_type_and_status
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

sub upgrade_release_type
{
    my $type_id = shift;

    # Type constants used to be 0 indexed, but as they are now in the database
    # they are indexed from 1.
    $type_id++ if defined $type_id;
    
    return $type_id;
}

sub upgrade_release_status
{
    my $status_id = shift;


    # Status' have their own table, so they don't have the 100 offset as before.
    # They are also indexed from 1, not 0
    $status_id -= 99 if defined $status_id;

    return $status_id;
}

sub upgrade_type_and_status
{
    my $type_and_status = shift;

    my ($type_id, $status_id) = split /,/, $type_and_status;
    if ($type_id && $type_id >= 100) {
        ($type_id, $status_id) = (undef, $type_id);
    }

    $type_id = upgrade_release_type($type_id);
    $status_id = upgrade_release_status($status_id);

    return ($type_id, $status_id);
}

1;
