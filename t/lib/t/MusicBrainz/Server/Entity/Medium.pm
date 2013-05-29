package t::MusicBrainz::Server::Entity::Medium;
use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::Track';

test 'length' => sub {

    my $medium = Medium->new();

    ok (!defined $medium->length, "empty medium has no length");

    $medium->add_track (Track->new(name => 'Courtesy', length => 193000));
    $medium->add_track (Track->new(name => 'Otis',     length => 156000));
    $medium->add_track (Track->new(name => 'Focus',    length => 162000));

    is ($medium->length, 511000, "medium has correct length from tracks");
};

1;
