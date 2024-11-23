package t::MusicBrainz::Server::Data::Recording;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::Search;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database($test->c, '+recording');

my $rec_data = MusicBrainz::Server::Data::Recording->new(c => $test->c);

my $rec = $rec_data->get_by_id(1);
is ( $rec->id, 1 );
is ( $rec->gid, '54b9d183-7dab-42ba-94a3-7388a66604b8' );
is ( $rec->name, 'King of the Mountain' );
is ( $rec->artist_credit_id, 1 );
is ( $rec->length, undef );
is ( $rec->edits_pending, 0 );

$rec = $rec_data->get_by_gid('54b9d183-7dab-42ba-94a3-7388a66604b8');
is ( $rec->id, 1 );
is ( $rec->gid, '54b9d183-7dab-42ba-94a3-7388a66604b8' );
is ( $rec->name, 'King of the Mountain' );
is ( $rec->artist_credit_id, 1 );
is ( $rec->length, undef );
is ( $rec->edits_pending, 0 );

my ($recs, $hits) = $rec_data->find_by_artist(1, 100, 0);
is( $hits, 17 );
is( scalar(@$recs), 17 );
is( $recs->[0]->name, '[pregap]' );
is( $recs->[1]->name, 'A Coral Room' );
is( $recs->[14]->name, 'Sunset' );
is( $recs->[15]->name, q(The Painter's Link) );

my $annotation = $rec_data->annotation->get_latest(1);
is ( $annotation->text, 'Annotation' );


$rec = $rec_data->get_by_gid('0986e67c-6b7a-40b7-b4ba-c9d7583d6426');
is ( $rec->id, 1 );
is ( $rec->gid, '54b9d183-7dab-42ba-94a3-7388a66604b8' );

my $rec_map = $rec_data->get_by_gids('0986e67c-6b7a-40b7-b4ba-c9d7583d6426', '54b9d183-7dab-42ba-94a3-7388a66604b8');
is ( $rec_map->{'0986e67c-6b7a-40b7-b4ba-c9d7583d6426'}->id, 1 );
is ( $rec_map->{'54b9d183-7dab-42ba-94a3-7388a66604b8'}->id, 1 );

my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my $results;
($results, $hits) = $search->search('recording', 'coral', 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, 'A Coral Room' );


$test->c->sql->begin;

$rec = $rec_data->insert({
        name => 'Traits',
        artist_credit => 1,
        comment => 'Drum & bass track',
    });
ok($rec->{id} > 16);

$rec = $rec_data->get_by_id($rec->{id});
is($rec->name, 'Traits');
is($rec->artist_credit_id, 1);
is($rec->comment, 'Drum & bass track');
ok(defined $rec->gid);

$rec_data->update($rec->id, {
        name => 'Traits (remix)',
        comment => 'New remix',
    });

$rec = $rec_data->get_by_id($rec->id);
is($rec->name, 'Traits (remix)');
is($rec->comment, 'New remix');

$rec_data->delete($rec->id);
$rec = $rec_data->get_by_id($rec->id);
ok(!defined $rec);

$test->c->sql->commit;

# Both #1 and #2 are in the DB
$rec = $rec_data->get_by_id(1);
ok(defined $rec);
$rec = $rec_data->get_by_id(2);
ok(defined $rec);

# Merge #2 into #1
$test->c->sql->begin;
$rec_data->merge(1, 2);
$test->c->sql->commit;

# Only #1 is now in the DB
$rec = $rec_data->get_by_id(1);
ok(defined $rec);
$rec = $rec_data->get_by_id(2);
ok(!defined $rec);

my @entities = map { $rec_data->get_by_id($_) } qw(1 8 14);

my $appears = $rec_data->appears_on(\@entities, 2);
$results = $appears->{1}->{results};

is ($appears->{8}->{results}->[0]->name, 'Aerial', 'recording 8 appears on Aerial');
is ($appears->{1}->{hits}, 4, 'recording 1 appears on four release groups');
is (scalar @$results, 2, ' ... of which two have been returned');
is ($results->[0]->name, 'エアリアル', 'recording 0 appears on エアリアル');
is ($results->[1]->name, 'Aerial', 'recording 1 appears on Aerial');

};

test q(Deleting a recording that's in a collection) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($c, '+recording');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
        SQL

    my $recording = $c->model('Recording')->insert({ name => 'Test123', artist_credit => 1});

    my $collection = $c->model('Collection')->insert(5, {
        description => '',
        editor_id => 5,
        name => 'Collection123',
        public => 0,
        type_id => 12,
    });

    $c->model('Collection')->add_entities_to_collection('recording', $collection->{id}, $recording->{id});
    $c->model('Recording')->delete($recording->{id});

    ok(!$c->model('Recording')->get_by_id($recording->{id}));
};

test q(Merging a recording that's in a collection) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
    MusicBrainz::Server::Test->prepare_test_database($c, '+recording');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
        SQL

    my $recording1 = $c->model('Recording')->insert({ name => 'Test123', artist_credit => 1 });
    my $recording2 = $c->model('Recording')->insert({ name => 'Test456', artist_credit => 1 });

    my $collection = $c->model('Collection')->insert(5, {
        description => '',
        editor_id => 5,
        name => 'Collection123',
        public => 0,
        type_id => 12,
    });

    $c->model('Collection')->add_entities_to_collection('recording', $collection->{id}, $recording1->{id});
    $c->model('Recording')->merge($recording2->{id}, $recording1->{id});

    ok($c->sql->select_single_value('SELECT 1 FROM editor_collection_recording WHERE recording = ?', $recording2->{id}));
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
