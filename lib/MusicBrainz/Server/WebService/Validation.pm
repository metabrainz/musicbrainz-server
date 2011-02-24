package MusicBrainz::Server::WebService::Validation;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( gid )],
};

use Data::TreeValidator::Sugar qw( branch leaf );
use MusicBrainz::Server::Validation qw( is_valid_gid );

sub gid {
    return leaf(
        constraints => [ sub {
            die 'Invalid MBID'
                unless is_valid_gid(shift);
        } ]
    );
}

1;
