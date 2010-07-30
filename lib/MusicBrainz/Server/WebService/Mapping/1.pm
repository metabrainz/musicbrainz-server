package MusicBrainz::Server::WebService::Mapping::1;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( map_type )]
};

my %type_map = (
    url => 'Url',
);

sub map_type {
    my $type = shift;
    return $type_map{$type};
}

1;
