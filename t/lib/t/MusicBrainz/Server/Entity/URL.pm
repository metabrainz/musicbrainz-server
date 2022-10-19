package t::MusicBrainz::Server::Entity::URL;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::URL;

test 'pretty name is decoded' => sub {

my $url = MusicBrainz::Server::Entity::URL->new(
    url => 'http://www.discogs.com/artist/%D0%97%D0%B5%D0%BC%D1%84%D0%B8%D1%80%D0%B0',
);

is ($url->pretty_name => 'http://www.discogs.com/artist/Земфира');

};

test 'pretty name is not decoded if the URL is not UTF-8' => sub {

my $url = MusicBrainz::Server::Entity::URL->new(
    url => 'http://www.invalid.fail/%FC'
);

is ($url->pretty_name => 'http://www.invalid.fail/%FC')

};

1;
