package t::MusicBrainz::Server::Data::ReleaseGroup;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

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
memory_cycle_ok($rg_data);

my $rg = $rg_data->get_by_id(1);
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 2 );
memory_cycle_ok($rg_data);
memory_cycle_ok($rg);

$rg = $rg_data->get_by_gid('7b5d22d0-72d7-11de-8a39-0800200c9a66');
is( $rg->id, 1 );
is( $rg->gid, "7b5d22d0-72d7-11de-8a39-0800200c9a66" );
is( $rg->name, "Release Group" );
is( $rg->artist_credit_id, 1 );
is( $rg->type_id, 1 );
is( $rg->edits_pending, 2 );
memory_cycle_ok($rg_data);
memory_cycle_ok($rg);

my ($rgs, $hits) = $rg_data->find_by_artist(1, 100);
is( $hits, 2 );
is( scalar(@$rgs), 2 );
is( $rgs->[0]->id, 1 );
is( $rgs->[1]->id, 2 );
memory_cycle_ok($rg_data);
memory_cycle_ok($rgs);

($rgs, $hits) = $rg_data->find_by_track_artist(3, 100);
is( $hits, 1 );
is( scalar(@$rgs), 1 );
ok( (grep { $_->id == 5 } @$rgs), 'found release group 5' );
ok( (grep { $_->id == 4 } @$rgs) == 0, 'did not find release group 4');
memory_cycle_ok($rg_data);
memory_cycle_ok($rgs);

my $release_data = MusicBrainz::Server::Data::Release->new(c => $test->c);
my $release = $release_data->get_by_id(1);
isnt( $release, undef );
is( $release->release_group, undef );
$rg_data->load($release);
isnt( $release->release_group, undef );
is( $release->release_group->id, 1 );
memory_cycle_ok($rg_data);
memory_cycle_ok($release);

my $annotation = $rg_data->annotation->get_latest(1);
is ( $annotation->text, "Annotation" );

memory_cycle_ok($rg_data);
memory_cycle_ok($annotation);

$rg = $rg_data->get_by_gid('77637e8c-be66-46ea-87b3-73addc722fc9');
is ( $rg->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my $results;
($results, $hits) = $search->search("release_group", "release group", 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->id, 1 );
memory_cycle_ok($results);

my $sql = $test->c->sql;
my $raw_sql = $test->c->raw_sql;
$sql->begin;
$raw_sql->begin;

$rg = $rg_data->insert({
        name => 'My Demons',
        artist_credit => 1,
        type_id => 1,
        comment => 'Dubstep album',
    });
memory_cycle_ok($rg_data);

ok(defined $rg);
isa_ok($rg, 'MusicBrainz::Server::Entity::ReleaseGroup');
ok($rg->id > 1);
ok($rg->gid);

$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Demons');
is($rg->type_id, 1);
is($rg->comment, 'Dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->update($rg->id, { name => 'My Angels', comment => 'Fake dubstep album' });
memory_cycle_ok($rg_data);

$rg = $rg_data->get_by_id($rg->id);
is($rg->name, 'My Angels');
is($rg->type_id, 1);
is($rg->comment, 'Fake dubstep album');
is($rg->artist_credit_id, 1);

$rg_data->delete($rg->id);
memory_cycle_ok($rg_data);

$rg = $rg_data->get_by_id($rg->id);
ok(!defined $rg);

$rg_data->merge(1, 2);
memory_cycle_ok($rg_data);

$rg = $rg_data->get_by_id(2);
ok(!defined $rg);

$rg = $rg_data->get_by_id(1);
ok(defined $rg);

$raw_sql->commit;
$sql->commit;

};

1;
