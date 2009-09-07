#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;
use_ok 'MusicBrainz::Server::Entity::WikiDocPage';

my $page = MusicBrainz::Server::Entity::WikiDocPage->new(
    title => 'About MusicBrainz',
    version => 14508,
    content => '<p>Hello</p>');

is($page->title, 'About MusicBrainz');
is($page->version, 14508);
is($page->content, '<p>Hello</p>');
