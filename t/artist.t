use strict;
use warnings;

use Test::More tests => 15;

BEGIN { use_ok('MusicBrainz::Server::Artist') }

# Seed the mock database...
use DBI;
use ModDefs;

my @test_artist_data = (
    ['id', 'name'        , 'gid'                                 , 'modpending', 'sortname'    , 'page'  , 'begindate' , 'enddate'   , 'type', 'quality', 'modpending_qual'],
    [20  , 'Art of Noise', 'be899560-1570-402e-9f95-3182898a8b70', 0           , 'Art of Noise', 87721479, '1983-00-00', '2000-00-00', 2     , 1        , 0                ],
);

my $dbh = DBI->connect('DBI:Mock:', '', '');
$dbh->{mock_add_resultset} = \@test_artist_data;

my $artist = new MusicBrainz::Server::Artist($dbh);
$artist->id(20);
$artist->LoadFromId;

ok (defined $artist, 'MB::S::Artist->new returned an object');
isa_ok($artist, 'MusicBrainz::Server::Artist', 'MB::S::Artist->new returned a correctly blessed object');

is($artist->id,                      $test_artist_data[1]->[0]);
is($artist->name,                    $test_artist_data[1]->[1]);
is($artist->mbid,                    $test_artist_data[1]->[2]);
is($artist->has_mod_pending,         $test_artist_data[1]->[3]);
is($artist->sort_name,               $test_artist_data[1]->[4]);
is($artist->begin_date,              $test_artist_data[1]->[6]);
is($artist->end_date,                $test_artist_data[1]->[7]);
is($artist->type,                    $test_artist_data[1]->[8]);
is($artist->quality,                 $test_artist_data[1]->[9]);
is($artist->quality_has_mod_pending, $test_artist_data[1]->[10]);

TODO: {
    local $TODO = 'dates should return a DateTime instance';

    isa_ok($artist->begin_date, 'DateTime');
    isa_ok($artist->end_date, 'DateTime');
}
