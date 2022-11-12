package t::MusicBrainz::Server::Entity::WikiDocPage;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::WikiDocPage;

test all => sub {

my $page = MusicBrainz::Server::Entity::WikiDocPage->new(
    title => 'About MusicBrainz',
    version => 14508,
    content => '<p>Hello</p>');

is($page->title, 'About MusicBrainz');
is($page->version, 14508);

};

1;
