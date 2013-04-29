package MusicBrainz::Server::ControllerUtils::Release;

use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( load_release_events )]
};

sub load_release_events {
    my ($c, @releases) = @_;
    $c->model('Release')->load_release_events(@releases);
    $c->model('Area')->load(map { $_->all_events } @releases);
    $c->model('Area')->load_codes(map { $_->country } map { $_->all_events } @releases);
};

1;
