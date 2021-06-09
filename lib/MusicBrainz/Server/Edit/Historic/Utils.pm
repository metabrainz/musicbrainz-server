package MusicBrainz::Server::Edit::Historic::Utils;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw(
        get_historic_type
        upgrade_date
        upgrade_id
        upgrade_type
        upgrade_release_type
        upgrade_release_status
        upgrade_type_and_status
    )]
};

use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Constants qw(
    %HISTORICAL_RELEASE_GROUP_TYPES
);
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

sub upgrade_date
{
    my $date = shift;
    $date =~ /\s*(\d{4})?-?(\d{1,2})?-?(\d{1,2})?\s*/;
    my $info = {};
    $info->{year} = $1 if ($1 && $1 > 0);
    $info->{month} = $2 if ($2 && $2 > 0);
    $info->{day} = $3 if ($3 && $3 > 0);
    return $info;
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
    shift;
}

sub upgrade_release_status
{
    my $status_id = shift;

    # Status' have their own table, so they don't have the 100 offset as before.
    # They are also indexed from 1, not 0
    return unless defined $status_id && $status_id ne "";
    return $status_id - 99;
}

sub upgrade_type_and_status
{
    my $type_and_status = shift;
    return (undef, undef) unless $type_and_status;

    my ($type_id, $status_id) = split /,/, $type_and_status;
    if ($type_id && $type_id >= 100) {
        ($type_id, $status_id) = (undef, $type_id);
    }

    $type_id = upgrade_release_type($type_id);
    $status_id = upgrade_release_status($status_id);

    return ($type_id, $status_id);
}

sub get_historic_type {
    my ($type_id, $loaded) = @_;

    if (!$type_id) {
        return undef;
    }
    
    my $loaded_type = to_json_object($loaded->{ReleaseGroupType}{ $type_id });

    if ($loaded_type) {
        return $loaded_type;
    }

    my $name = $HISTORICAL_RELEASE_GROUP_TYPES{$type_id};

    if (!$name) {
        return undef;
    }

    my $mock_type = MusicBrainz::Server::Entity::ReleaseGroupType->new(
        historic => 1,
        id => $type_id,
        name => $name,
    );

    return to_json_object($mock_type);
}

1;
