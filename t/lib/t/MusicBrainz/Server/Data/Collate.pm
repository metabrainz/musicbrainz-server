package t::MusicBrainz::Server::Data::Collate;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c);
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+postgresql_musicbrainz_collate');

    my @expected = qw/
        Latin Ελληνικά Русский ქართული Հայերեն עברית العربية हिन्दी বাংলা
        ਪੰਜਾਬੀ ಕನ್ನಡ සිංහල ไทย ᏣᎳᎩ ᚠᚢᚦᚨᚱ 한국어 カタカナ ひらがな ㄅㄆㄇㄈ
        𐎀𐎁𐎂𐎃𐎄𐎅 漢字 /;

    my $rec_data = MusicBrainz::Server::Data::Recording->new(c => $test->c);
    my ($recs, undef) = $rec_data->find_by_artist(4, 100, 0);

    is($expected[$_], $recs->[$_]->name, "Expected recording name \#$_") for (0..20)
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
