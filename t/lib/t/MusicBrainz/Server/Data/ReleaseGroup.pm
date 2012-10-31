package t::MusicBrainz::Server::Data::ReleaseGroup;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+releasegroup');

my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $test->c);

my $rg = $rg_data->get_by_id(1);
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->primary_type_id, 1 );
is( $rg->edits_pending, 2 );

$rg = $rg_data->get_by_gid('7b5d22d0-72d7-11de-8a39-0800200c9a66');
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->primary_type_id, 1 );
is( $rg->edits_pending, 2 );

my ($rgs, $hits) = $rg_data->find_by_artist(1, 100, 0);
is( $hits, 2 );
is( scalar(@$rgs), 2 );
is( $rgs->[0]->id, 1 );
is( $rgs->[1]->id, 2 );

($rgs, $hits) = $rg_data->find_by_track_artist(3, 100, 0);
is( $hits, 1 );
is( scalar(@$rgs), 1 );
ok( (grep { $_->id == 5 } @$rgs), 'found release group 5' );
ok( (grep { $_->id == 4 } @$rgs) == 0, 'did not find release group 4');

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);
my $release = $release_data->get_by_id(1);
isnt( $release, undef );
is( $release->release_group, undef );
$rg_data->load($release);
isnt( $release->release_group, undef );
is( $release->release_group->id, 1 );

my $annotation = $rg_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );


$rg = $rg_data->get_by_gid('77637e8c-be66-46ea-87b3-73addc722fc9');
is ( $rg->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my $results;
($results, $hits) = $search->search("release_group", "release group", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->id, 1 );

my $sql = $test->c->sql;
$sql->begin;

$rg = $rg_data->insert({
        name => 'My Demons',
        artist_credit => 1,
        primary_type_id => 1,
        comment => 'Dubstep album',
    });

ok(defined $rg);
isa_ok($rg, 'MusicBrainz::Server::Entity::ReleaseGroup');
ok($rg->id > 1);
ok($rg->gid);

$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Demons');
is($rg->primary_type_id, 1);
is($rg->comment, 'Dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->update($rg->id, { name => 'My Angels', comment => 'Fake dubstep album' });

$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Angels');
is($rg->primary_type_id, 1);
is($rg->comment, 'Fake dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->delete($rg->id);

$rg = $rg_data->get_by_id($rg->id);
ok(!defined $rg);

$rg_data->merge(1, 2);

$rg = $rg_data->get_by_id(2);
ok(!defined $rg);

$rg = $rg_data->get_by_id(1);
ok(defined $rg);

$sql->commit;

};

test 'Delete release groups with secondary types' => sub {
    my $test = shift;
    $test->c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');
INSERT INTO release_name (id, name) VALUES (1, 'Release Group');
INSERT INTO release_group (id, gid, name, artist_credit, type, comment, edits_pending)
    VALUES (1, '7b5d22d0-72d7-11de-8a39-0800200c9a66', 1, 1, 1, 'Comment', 2);
INSERT INTO release_group_secondary_type (id, name) VALUES (1, 'Remix');
INSERT INTO release_group_secondary_type_join (release_group, secondary_type)
    VALUES (1, 1);
EOSQL

    $test->c->model('ReleaseGroup')->delete(1);
    ok(!defined $test->c->model('ReleaseGroup')->get_by_id(1));
};

1;
