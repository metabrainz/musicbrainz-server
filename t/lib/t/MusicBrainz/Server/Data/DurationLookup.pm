package t::MusicBrainz::Server::Data::DurationLookup;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::DurationLookup;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_durationlookup');

my $sql = $test->c->sql;
my $raw_sql = $test->c->raw_sql;

my $lookup_data = MusicBrainz::Server::Data::DurationLookup->new(c => $test->c);
does_ok($lookup_data, 'MusicBrainz::Server::Data::Role::Context');
memory_cycle_ok($lookup_data);

my $result = $lookup_data->lookup("1 7 171327 150 22179 49905 69318 96240 121186 143398", 10000);
ok ( scalar(@$result) > 0, 'found results' );
is ( defined $result->[0] && $result->[0]->medium->tracklist_id, 1 );
is ( defined $result->[0] && $result->[0]->distance, 1 );
is ( defined $result->[0] && $result->[0]->medium_id, 3 );

memory_cycle_ok($lookup_data);
memory_cycle_ok($result);

$result = $lookup_data->lookup("1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877", 10000);
ok ( scalar(@$result) > 0, 'found results' );
is ( defined $result->[0] && $result->[0]->medium->tracklist_id, 2 );
is ( defined $result->[0] && $result->[0]->distance, 1 );
is ( defined $result->[0] && $result->[0]->medium_id, 4 );

memory_cycle_ok($lookup_data);
memory_cycle_ok($result);

};

1;
