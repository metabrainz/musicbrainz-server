package t::MusicBrainz::Server::Edit::Area::Merge;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_AREA_MERGE );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Can merge areas are used as entity areas' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    $c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name, area, begin_area, end_area)
  VALUES (5, 'c5655a7c-bba0-46aa-a8fd-db707d47aa5c', 1, 1, 13, 13, 13);

INSERT INTO label_name (id, name) VALUES (1, 'Artist');
INSERT INTO label (id, gid, name, sort_name, area)
  VALUES (5, 'c5655a7c-bba0-46aa-a8fd-db707d47aa5c', 1, 1, 13);
EOSQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_AREA_MERGE,
        editor_id => 1,
        old_entities => [ { id => 13, name => 'Australia' } ],
        new_entity => { id => 81, name => 'Germany' }
    );

    is exception { $edit->accept }, undef;
};

test 'Can merge country areas' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    $c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
VALUES (1, '8469c1b7-04a1-4ca7-a090-a5ed2df2e7ac', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Release');

INSERT INTO release_group (id, gid, name, artist_credit)
VALUES (1, '14928cab-363c-4457-951e-9b1c3ca404cd', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
VALUES (1, 'a2d13b15-4002-4d04-8a08-b9a9a7fbe9ad', 1, 1, 1);

INSERT INTO release_country (release, country) VALUES (1, 13);
EOSQL

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_AREA_MERGE,
        editor_id => 1,
        old_entities => [ { id => 13, name => 'Australia' } ],
        new_entity => { id => 81, name => 'Germany' }
    );

    is exception { $edit->accept }, undef;
};

1;

