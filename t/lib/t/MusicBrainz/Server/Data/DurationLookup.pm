package t::MusicBrainz::Server::Data::DurationLookup;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::DurationLookup;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_durationlookup');

my $sql = $test->c->sql;

my $lookup_data = MusicBrainz::Server::Data::DurationLookup->new(c => $test->c);
does_ok($lookup_data, 'MusicBrainz::Server::Data::Role::Context');

my $result = $lookup_data->lookup("1 7 171327 150 22179 49905 69318 96240 121186 143398", 10000);
ok ( scalar(@$result) > 0, 'found results' );

if (my ($result) = grep { $_->medium_id == 1 } @$result) {
    ok ($result, 'returned medium 1');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 1 );
    is ( $result->medium_id, 1 );
}

if (my ($result) = grep { $_->medium_id == 3 } @$result) {
    ok ($result, 'returned medium 3');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 3 );
    is ( $result->medium_id, 3 );
}


$result = $lookup_data->lookup("1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877", 10000);

if (my ($result) = grep { $_->medium_id == 2 } @$result) {
    ok ($result, 'returned medium 1');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 2 );
    is ( $result->medium_id, 2 );
}

if (my ($result) = grep { $_->medium_id == 4 } @$result) {
    ok ($result, 'returned medium 4');
    is ( $result->distance, 1 );
    is ( $result->medium->id, 4 );
    is ( $result->medium_id, 4 );
}


};

1;
