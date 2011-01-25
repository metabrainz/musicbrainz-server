package t::MusicBrainz::Server::Data::ReleaseLabel;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::ReleaseLabel';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+releaselabel');

my $rl_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $test->c);

my $rl = $rl_data->get_by_id(1);
is( $rl->id, 1 );
is( $rl->release_id, 1 );
is( $rl->label_id, 1 );
is( $rl->catalog_number, "ABC-123" );

ok( !$rl_data->load() );

my ($rls, $hits) = $rl_data->find_by_label(1, 100);
is( $hits, 4 );
is( scalar(@$rls), 4 );
is( $rls->[0]->release->id, 3 );
is( $rls->[0]->catalog_number, "343 960 2" );
is( $rls->[1]->release->id, 4 );
is( $rls->[1]->catalog_number, "82796 97772 2" );
is( $rls->[2]->release->id, 1 );
is( $rls->[2]->catalog_number, "ABC-123" );
is( $rls->[3]->release->id, 1 );
is( $rls->[3]->catalog_number, "ABC-123-X" );

my $sql = $test->c->sql;
$sql->begin;

$rl_data->merge_labels(1, 2);
($rls, $hits) = $rl_data->find_by_label(1, 100);
is($hits, 4);

($rls, $hits) = $rl_data->find_by_label(2, 100);
is($hits, 0);

$sql->commit;

};

1;
