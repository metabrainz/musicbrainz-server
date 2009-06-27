use strict;
use warnings;
use Test::More tests => 58;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::Artist';
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->mb->dbh);
$sql->Begin;

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
does_ok($artist_data, 'MusicBrainz::Server::Data::Editable');

my $artist = $artist_data->get_by_id(3);
is ( $artist->id, 3 );
is ( $artist->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $artist->name, "Test Artist" );
is ( $artist->sort_name, "Artist, Test" );
is ( $artist->begin_date->year, 2008 );
is ( $artist->begin_date->month, 1 );
is ( $artist->begin_date->day, 2 );
is ( $artist->end_date->year, 2009 );
is ( $artist->end_date->month, 3 );
is ( $artist->end_date->day, 4 );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, 'Yet Another Test Artist' );

$artist = $artist_data->get_by_id(4);
is ( $artist->id, 4 );
is ( $artist->gid, "945c079d-374e-4436-9448-da92dedef3cf" );
is ( $artist->name, "Queen" );
is ( $artist->sort_name, "Queen" );
is ( $artist->begin_date->year, undef );
is ( $artist->begin_date->month, undef );
is ( $artist->begin_date->day, undef );
is ( $artist->end_date->year, undef );
is ( $artist->end_date->month, undef );
is ( $artist->end_date->day, undef );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, undef );

my $annotation = $artist_data->annotation->get_latest(3);
like ( $annotation->text, qr/Test annotation 1/ );

$artist_data->annotation->delete(3);
$annotation = $artist_data->annotation->get_latest(3);
ok(!defined $annotation);

$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
is ( $artist->id, 4 );

$sql->Commit;

my $search = MusicBrainz::Server::Data::Search->new(c => $c);
my ($results, $hits) = $search->search("artist", "bush", 10);
is( $hits, 3 );
is( scalar(@$results), 3 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, "Kate Bush" );
is( $results->[0]->entity->sort_name, "Bush, Kate" );

$sql->Begin;

my %names = $artist_data->find_or_insert_names('Kate Bush', 'Bush, Kate', 'Massive Attack');
is(keys %names, 3);
is($names{'Kate Bush'}, 9);
is($names{'Bush, Kate'}, 10);
ok($names{'Massive Attack'} > 10);

$artist = $artist_data->insert({
        name => 'Queen',
        sort_name => 'David Bowie',
        type => 2,
        begin_date => { year => 2000, month => 1 },
    });
isa_ok($artist, 'MusicBrainz::Server::Entity::Artist');
ok($artist->id > 9);

$artist = $artist_data->get_by_id($artist->id);
is($artist->name, 'Queen');
is($artist->sort_name, 'David Bowie');
ok(!$artist->begin_date->is_empty);
is($artist->begin_date->year, 2000);
is($artist->begin_date->month, 1);
is($artist->begin_date->day, undef);
ok($artist->end_date->is_empty);
is($artist->type_id, 2);
ok(defined $artist->gid);

$artist_data->update($artist->id, {
        sort_name => 'Kate Bush',
        end_date => { year => 2009 }
    });

$artist = $artist_data->get_by_id($artist->id);
is($artist->sort_name, 'Kate Bush');
ok(!$artist->end_date->is_empty);
is($artist->end_date->year, 2009);

$artist_data->delete($artist->id);
$artist = $artist_data->get_by_id($artist->id);
ok(!defined $artist);

$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
is ( $artist->id, 4 );

$artist_data->remove_gid_redirects(4);
$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
ok(!defined $artist);

$artist_data->add_gid_redirects(
    '20bb5c20-5dbf-11de-8a39-0800200c9a66' => 3,
    '2adff2b0-5dbf-11de-8a39-0800200c9a66' => 5,
);

$artist = $artist_data->get_by_gid('20bb5c20-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 3);

$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 5);

$artist_data->update_gid_redirects(5, 3);

$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 3);

$sql->Commit;
