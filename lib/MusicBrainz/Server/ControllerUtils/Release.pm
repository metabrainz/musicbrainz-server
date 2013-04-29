package MusicBrainz::Server::ControllerUtils::Release;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( load_release_events )]
};

sub load_release_events {
    my ($c, @releases) = @_;
    $c->model('Release')->load_release_events(@releases);
    $c->model('Country')->load(map { $_->all_events } @releases);
};

1;
