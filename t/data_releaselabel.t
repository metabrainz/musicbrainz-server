use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::ReleaseLabel';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+releaselabel');

my $rl_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);

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

my $sql = Sql->new($c->dbh);
$sql->Begin;

$rl_data->merge_labels(1, 2);
($rls, $hits) = $rl_data->find_by_label(1, 100);
is($hits, 4);

($rls, $hits) = $rl_data->find_by_label(2, 100);
is($hits, 0);

$sql->Commit;

done_testing;
