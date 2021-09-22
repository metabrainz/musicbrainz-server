package t::MusicBrainz::Server::Data::Artist;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;
use Test::Deep qw( cmp_set );

use MusicBrainz::Server::Data::Artist;

use DateTime;
use DBDefs;
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Search;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Constants qw($DARTIST_ID $VARTIST_ID);
use Sql;

with 't::Edit';
with 't::Context';

test 'Test find_by_work' => sub {
    my $test = shift;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO work (id, gid, name)
            VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen');

        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Test Artist', 'Test Artist', ''),
                   (2, '145c079d-374e-4436-9448-da92dedef3cf', 'Test Artist', 'Test Artist', 'Other test artist');

        INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Test Artist', 1);
        INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
            VALUES (1, 0, 1, 'Test Artist', '');

        INSERT INTO recording (id, gid, name, artist_credit)
            VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'Recording', 1);

        INSERT INTO link (id, link_type, attribute_count)
            VALUES (1, 278, 0), (2, 167, 0);

        INSERT INTO l_artist_work (id, entity0, entity1, link) VALUES (1, 2, 1, 1);
        INSERT INTO l_recording_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
        SQL

    my ($artists, $hits) = $test->c->model('Artist')->find_by_work(1, 100, 0);
    is($hits, 2);
    cmp_set([ map { $_->id } @$artists ], [ 1, 2 ]);
};

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_artist');

my $sql = $test->c->sql;
$sql->begin;

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);
does_ok($artist_data, 'MusicBrainz::Server::Data::Role::Editable');

# ----
# Test fetching artists:

# An artist with all attributes populated
my $artist = $artist_data->get_by_id(3);
is ( $artist->id, 3 );
is ( $artist->gid, '745c079d-374e-4436-9448-da92dedef3ce' );
is ( $artist->name, 'Test Artist' );
is ( $artist->sort_name, 'Artist, Test' );
is ( $artist->begin_date->year, 2008 );
is ( $artist->begin_date->month, 1 );
is ( $artist->begin_date->day, 2 );
is ( $artist->end_date->year, 2009 );
is ( $artist->end_date->month, 3 );
is ( $artist->end_date->day, 4 );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, 'Yet Another Test Artist' );

# Test loading metadata
$artist_data->load_meta($artist);
is ( $artist->rating, 70 );
is ( $artist->rating_count, 4 );
isnt ( $artist->last_updated, undef );

# An artist with the minimal set of required attributes
$artist = $artist_data->get_by_id(4);
is ( $artist->id, 4 );
is ( $artist->gid, '945c079d-374e-4436-9448-da92dedef3cf' );
is ( $artist->name, 'Minimal Artist' );
is ( $artist->sort_name, 'Minimal Artist' );
is ( $artist->begin_date->year, undef );
is ( $artist->begin_date->month, undef );
is ( $artist->begin_date->day, undef );
is ( $artist->end_date->year, undef );
is ( $artist->end_date->month, undef );
is ( $artist->end_date->day, undef );
is ( $artist->edits_pending, 0 );
is ( $artist->comment, '' );

# ---
# Test annotations

# Fetching annotations
my $annotation = $artist_data->annotation->get_latest(3);
like ( $annotation->text, qr/Test annotation 1/ );


# Merging annotations
$artist_data->annotation->merge(4, 5, 3, 6);
$annotation = $artist_data->annotation->get_latest(3);
ok(!defined $annotation);

$annotation = $artist_data->annotation->get_latest(4);

like($annotation->text, qr/Test annotation 1/, 'has annotation 1');
like($annotation->text, qr/Test annotation 2/, 'has annotation 2');
like($annotation->text, qr/Duplicate annotation/, 'has third annotation');

like($annotation->text, qr/annotation 2.*annotation 1/s,
     'annotation from merge target is first (MBS-3452)');

unlike($annotation->text, qr/Duplicate annotation.*Duplicate annotation/s,
       'duplicate annotation appears only once (MBS-6164)');

# Deleting annotations
$artist_data->annotation->delete(4);
$annotation = $artist_data->annotation->get_latest(4);
ok(!defined $annotation);


$sql->commit;

# ---
# Searching for artists
my $search = MusicBrainz::Server::Data::Search->new(c => $test->c);
my ($results, $hits) = $search->search('artist', 'test', 10);
is( $hits, 1 );
is( scalar(@$results), 1 );
is( $results->[0]->position, 1 );
is( $results->[0]->entity->name, 'Test Artist' );
is( $results->[0]->entity->sort_name, 'Artist, Test' );


$sql->begin;

# ---
# Creating new artists
$artist = $artist_data->insert({
        name => 'New Artist',
        sort_name => 'Artist, New',
        comment => 'Artist comment',
        area_id => 221,
        type_id => 1,
        gender_id => 1,
        begin_date => { year => 2000, month => 1, day => 2 },
        end_date => { year => 1999, month => 3, day => 4 },
    });
ok($artist->{id} > 4);

$artist = $artist_data->get_by_id($artist->{id});
is($artist->name, 'New Artist');
is($artist->sort_name, 'Artist, New');
is($artist->begin_date->year, 2000);
is($artist->begin_date->month, 1);
is($artist->begin_date->day, 2);
is($artist->end_date->year, 1999);
is($artist->end_date->month, 3);
is($artist->end_date->day, 4);
is($artist->type_id, 1);
is($artist->gender_id, 1);
is($artist->area_id, 221);
is($artist->comment, 'Artist comment');
ok(defined $artist->gid);

# ---
# Updating artists
$artist_data->update($artist->id, {
        name => 'Updated Artist',
        sort_name => 'Artist, Updated',
        begin_date => { year => 1995, month => 4, day => 22 },
        end_date => { year => 1990, month => 6, day => 17 },
        type_id => undef,
        gender_id => 2,
        area_id => 222,
        comment => 'Updated comment',
    });


$artist = $artist_data->get_by_id($artist->id);
is($artist->name, 'Updated Artist');
is($artist->sort_name, 'Artist, Updated');
is($artist->begin_date->year, 1995);
is($artist->begin_date->month, 4);
is($artist->begin_date->day, 22);
is($artist->end_date->year, 1990);
is($artist->end_date->month, 6);
is($artist->end_date->day, 17);
is($artist->type_id, undef);
is($artist->gender_id, 2);
is($artist->area_id, 222);
is($artist->comment, 'Updated comment');

$artist_data->update($artist->id, {
        type_id => 2,
        gender_id => undef
    });
$artist = $artist_data->get_by_id($artist->id);
is($artist->type_id, 2);

$artist_data->delete($artist->id);
$artist = $artist_data->get_by_id($artist->id);
ok(!defined $artist);

# ---
# Gid redirections
$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
is ( $artist->id, 3 );

$artist_data->remove_gid_redirects(3);
$artist = $artist_data->get_by_gid('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11');
ok(!defined $artist);

$artist_data->add_gid_redirects(
    '20bb5c20-5dbf-11de-8a39-0800200c9a66' => 3,
    '2adff2b0-5dbf-11de-8a39-0800200c9a66' => 4,
);


$artist = $artist_data->get_by_gid('20bb5c20-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 3);

$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 4);

$artist_data->update_gid_redirects(3, 4);


$artist = $artist_data->get_by_gid('2adff2b0-5dbf-11de-8a39-0800200c9a66');
is($artist->id, 3);

$artist_data->merge(3, [ 4 ]);
$artist = $artist_data->get_by_id(4);
ok(!defined $artist);

$artist = $artist_data->get_by_id(3);
ok(defined $artist);
is($artist->name, 'Test Artist');

# ---
# Checking when an artist is in use or not

ok($artist_data->can_delete(3));

my $ac = $test->c->model('ArtistCredit')->find_or_insert(
    {
        names => [ { artist => { id => 3, name => 'Calibre' }, name => 'Calibre' } ]
    });
ok($artist_data->can_delete(3));

my $rec = $test->c->model('Recording')->insert({
    name => q(Love's Too Tight Too Mention),
    artist_credit => $ac,
    comment => 'Drum & bass track',
});

ok(!$artist_data->can_delete(3));

    # ---
    # Missing entities search
    $artist = $artist_data->insert({
        name => 'Test Artist',
        sort_name => 'Artist, Test',
        comment => 'J-Pop artist',
        area_id => 221,
        type_id => 1,
        gender_id => 1,
    });

    my $found = $artist_data->search_by_names('Test Artist', 'Minimal Artist');
    is(scalar @{ $found->{'Test Artist'} }, 2, 'Found two test artists');
    my @testartists = sort_by { $_->comment } @{ $found->{'Test Artist'} };
    is($testartists[0]->comment, 'J-Pop artist');
    is($testartists[1]->comment, 'Yet Another Test Artist');

$sql->commit;

};

test 'Merging with a cache' => sub {
    my $test = shift;

    my $opts = DBDefs->CACHE_MANAGER_OPTIONS;
    $opts->{profiles}{external}{options}{namespace} = 'mbtest:';

    my $c = $test->c->meta->clone_object(
        $test->c,
        cache_manager => MusicBrainz::Server::CacheManager->new(%$opts),
        models => {} # Need to reload models to use this new $c
    );

    my $cache = $c->cache_manager->_get_cache('external');

    MusicBrainz::Server::Test->prepare_test_database($c, '+data_artist');

    $c->sql->begin;

    my $artist1 = $c->model('Artist')->get_by_gid('745c079d-374e-4436-9448-da92dedef3ce');
    my $artist2 = $c->model('Artist')->get_by_gid('945c079d-374e-4436-9448-da92dedef3cf');

    for my $artist ($artist1, $artist2) {
        ok($cache->get('artist:' . $artist->gid), 'caches artist via GID');
        ok($cache->get('artist:' . $artist->id), 'caches artist via ID');
    }

    $c->model('Artist')->merge($artist1->id, [ $artist2->id ]);

    ok(!$cache->get('artist:' . $artist2->gid), 'artist 2 no longer in cache (by gid)');
    ok(!$cache->get('artist:' . $artist2->id), 'artist 2 no longer in cache (by id)');

    $c->sql->commit;
};

test 'Deny delete "Various Artists" trigger' => sub {
    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+special-purpose');

    like exception {
        $c->sql->do("DELETE FROM artist WHERE id = $VARTIST_ID")
    }, qr/ERROR:\s*Attempted to delete a special purpose row/;
};

test 'Deny delete "Deleted Artist" trigger' => sub {
    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+special-purpose');

    like exception {
        $c->sql->do("DELETE FROM artist WHERE id = $DARTIST_ID")
    }, qr/ERROR:\s*Attempted to delete a special purpose row/;
};

test 'Merging attributes' => sub {
    my $c = shift->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, '745c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name');

        INSERT INTO artist (
            id, gid, name, sort_name,
            begin_date_year, end_date_year, end_date_day, comment
        ) VALUES (
            4, '145c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name',
            2000, 2005, 12, 'Artist 4'
        );

        INSERT INTO artist (
            id, gid, name, sort_name,
            begin_date_year, begin_date_month, comment
        ) VALUES (
            5, '245c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name',
            2000, 06, 'Artist 5'
        );
        SQL

    $c->model('Artist')->merge(3, [4, 5]);
    my $artist = $c->model('Artist')->get_by_id(3);
    is($artist->begin_date->year, 2000);
    is($artist->begin_date->month, 6);
    is($artist->begin_date->day, undef);

    is($artist->end_date->year, 2005);
    is($artist->end_date->month, undef);
    is($artist->end_date->day, 12);
};

test 'Merging "ended" flag' => sub {
    my $c = shift->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, ended)
            VALUES (3, 'ac653796-bca1-4d2e-a92a-4ce5ef2efb0b', 'The Artist', 'Artist, The', FALSE),
                   (4, '0db63477-bc98-4aac-a76a-28d78971a07c', 'An Artist', 'Artist, An', TRUE);
        SQL

    $c->model('Artist')->merge(3, [4]);
    my $artist = $c->model('Artist')->get_by_id(3);
    ok($artist->ended, 'merge result retains "ended" flag (MBS-6763)');
};

test 'Merging attributes for VA' => sub {
    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+special-purpose');
    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, gender)
            VALUES (4, '745c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name', 3);

        INSERT INTO artist (
            id, gid, name, sort_name,
            begin_date_year, end_date_year, end_date_day, comment
        ) VALUES (
            5, '145c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name',
            2000, 2005, 12, 'Artist 4'
        );

        INSERT INTO artist (
            id, gid, name, sort_name,
            area, type, comment
        ) VALUES (
            6, '245c079d-374e-4436-9448-da92dedef3ce', 'artist name', 'artist name',
            222, 2, 'Artist 5'
        );
        SQL

    $c->model('Artist')->merge(1, [4, 5, 6]);
    my $artist = $c->model('Artist')->get_by_id(1);

    is($artist->begin_date->year, undef, 'begin date...');
    is($artist->begin_date->month, undef);
    is($artist->begin_date->day, undef);
    is($artist->end_date->year, undef, 'end date...');
    is($artist->end_date->month, undef);
    is($artist->end_date->day, undef);
    is($artist->area_id, undef, 'area is undef');
    is($artist->gender_id, undef, 'gender is undef');
    is($artist->type_id, 3, 'type is unchanged');
};

test 'Cannot edit an artist into something that would violate uniqueness' => sub {
    my $c = shift->c;
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (3, '745c079d-374e-4436-9448-da92dedef3ce', 'A', 'A', ''),
                   (4, '7848d7ce-d650-40c4-b98f-62fc037a678b', 'B', 'A', 'Comment');
        SQL

    my $conflicts_exception_ok = sub {
        my ($e, $target) = @_;

        isa_ok $e, 'MusicBrainz::Server::Exceptions::DuplicateViolation';
        is $e->conflict->id, $target;
    };

    ok !exception { $c->model('Artist')->update(4, { comment => '' }) };
    $conflicts_exception_ok->(
        exception { $c->model('Artist')->update(3, { name => 'B' }) },
        4
    );

    ok !exception { $c->model('Artist')->update(3, { name => 'B', comment => 'Unique' }) };
    $conflicts_exception_ok->(
        exception { $c->model('Artist')->update(3, { comment => '' }) },
        4
    );
};

test q(Deleting an artist that's in a collection) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+data_artist');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
        SQL

    my $artist = $c->model('Artist')->insert({ name => 'Test123', sort_name => 'Test123' });

    my $collection = $c->model('Collection')->insert(5, {
        description => '',
        editor_id => 5,
        name => 'Collection123',
        public => 0,
        type_id => 8,
    });

    $c->model('Collection')->add_entities_to_collection('artist', $collection->{id}, $artist->{id});
    $c->model('Artist')->delete($artist->{id});

    ok(!$c->model('Artist')->get_by_id($artist->{id}));
};

test q(Merging an artist that's in a collection) => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+data_artist');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
        SQL

    my $artist1 = $c->model('Artist')->insert({ name => 'Test123', sort_name => 'Test123' });
    my $artist2 = $c->model('Artist')->insert({ name => 'Test456', sort_name => 'Test456' });

    my $collection = $c->model('Collection')->insert(5, {
        description => '',
        editor_id => 5,
        name => 'Collection123',
        public => 0,
        type_id => 8,
    });

    $c->model('Collection')->add_entities_to_collection('artist', $collection->{id}, $artist1->{id});
    $c->model('Artist')->merge($artist2->{id}, [$artist1->{id}]);

    ok($c->sql->select_single_value('SELECT 1 FROM editor_collection_artist WHERE artist = ?', $artist2->{id}))
};

1;
