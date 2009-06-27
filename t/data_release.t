use strict;
use warnings;
use Test::More tests => 60;
use_ok 'MusicBrainz::Server::Data::Release';
use MusicBrainz::Server::Data::ReleaseLabel;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $release_data = MusicBrainz::Server::Data::Release->new(c => $c);

my $release = $release_data->get_by_id(1);
is( $release->id, 1 );
is( $release->gid, "f34c079d-374e-4436-9448-da92dedef3ce" );
is( $release->name, "Arrival" );
is( $release->artist_credit_id, 2 );
is( $release->release_group_id, 1 );
is( $release->status_id, 1 );
is( $release->packaging_id, 1 );
is( $release->country_id, 1 );
is( $release->date->year, 2009 );
is( $release->date->month, 5 );
is( $release->date->day, 8 );
is( $release->barcode, "731453398122" );
is( $release->edits_pending, 0 );

my $release_label_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);
$release_label_data->load($release);
ok( @{$release->labels} >= 2 );
is( $release->labels->[0]->label_id, 2 );
is( $release->labels->[0]->catalog_number, "ABC-123" );
is( $release->labels->[1]->label_id, 2 );
is( $release->labels->[1]->catalog_number, "ABC-123-X" );

my ($releases, $hits) = $release_data->find_by_artist(7, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->gid, "f205627f-b70a-409d-adbe-66289b614e80" );
is( $releases->[0]->date->day, 7 );
is( $releases->[1]->gid, "9b3d9383-3d2a-417f-bfbb-56f7c15f075b" );
is( $releases->[1]->date->day, 8 );

($releases, $hits) = $release_data->find_by_release_group(2, 100);
is( $hits, 2 );
is( scalar(@$releases), 2 );
is( $releases->[0]->gid, "f205627f-b70a-409d-adbe-66289b614e80" );
is( $releases->[0]->date->day, 7 );
is( $releases->[1]->gid, "9b3d9383-3d2a-417f-bfbb-56f7c15f075b" );
is( $releases->[1]->date->day, 8 );

my $annotation = $release_data->annotation->get_latest(1);
is ( $annotation->text, "Test annotation 4." );

$release = $release_data->get_by_gid('71dc55d8-0fc6-41c1-94e0-85ff2404997d');
is ( $release->id, 1 );

my %names = $release_data->find_or_insert_names('Arrival', 'Aerial', 'Protection');
is(keys %names, 3);
is($names{'Arrival'}, 1);
is($names{'Aerial'}, 2);
ok($names{'Protection'} > 4);

my $sql = Sql->new($c->mb->dbh);
$sql->Begin;
$release = $release_data->insert({
        name => 'Protection',
        artist_credit => 1,
        release_group => 1,
        packaging => 1,
        status => 1,
        date => { year => 2001, month => 2, day => 15 },
        barcode => '0123456789',
        country => 2
    });
$release = $release_data->get_by_id($release->id);
ok(defined $release);
is($release->name, 'Protection');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2001);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 2);

$release_data->update($release, {
        name => 'Blue Lines',
        country => 1,
        date => { year => 2002 },
    });
$release = $release_data->get_by_id($release->id);
ok(defined $release);
is($release->name, 'Blue Lines');
is($release->artist_credit_id, 1);
is($release->release_group_id, 1);
is($release->packaging_id, 1);
is($release->status_id, 1);
ok(!$release->date->is_empty);
is($release->date->year, 2002);
is($release->date->month, 2);
is($release->date->day, 15);
is($release->country_id, 1);

$release_data->delete($release);
$release = $release_data->get_by_id($release->id);
ok(!defined $release);
$sql->Commit;
