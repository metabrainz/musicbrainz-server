#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use Test::More;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_database($c, '+postgresql_musicbrainz_collate');

my @expected = qw/ 
Latin
Ελληνικά
Русский
ქართული
Հայերեն
עברית
العربية
हिन्दी
বাংলা
ਪੰਜਾਬੀ
ಕನ್ನಡ
සිංහල
ไทย
ᏣᎳᎩ
ᚠᚢᚦᚨᚱ
한국어
カタカナ
ひらがな
ㄅㄆㄇㄈ
𐎀𐎁𐎂𐎃𐎄𐎅
漢字

/;


my ($results, $hits) = $c->model('Recording')->find_by_artist (4, 100, 0);

foreach (0..20)
{
    is ($expected[$_], $results->[$_]->name);
}

done_testing;

1;
