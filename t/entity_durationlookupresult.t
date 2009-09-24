#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
BEGIN { use_ok 'MusicBrainz::Server::Entity::DurationLookupResult'; }

my $artist = MusicBrainz::Server::Entity::DurationLookupResult->new();
has_attribute_ok($artist, $_) for qw( distance medium_id medium );

done_testing
