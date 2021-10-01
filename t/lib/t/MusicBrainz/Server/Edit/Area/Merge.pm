package t::MusicBrainz::Server::Edit::Area::Merge;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

use MusicBrainz::Server::Constants qw( $EDIT_AREA_MERGE );
use MusicBrainz::Server::Constants qw( :edit_status );

test 'Can merge areas are used as entity areas' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, area, begin_area, end_area)
            VALUES (5, 'c5655a7c-bba0-46aa-a8fd-db707d47aa5c', 'Artist', 'Artist', 13, 13, 13);

        INSERT INTO label (id, gid, name, area)
            VALUES (5, 'c5655a7c-bba0-46aa-a8fd-db707d47aa5c', 'Artist', 13);
        SQL

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { location_editor => 1 });

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
    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '8469c1b7-04a1-4ca7-a090-a5ed2df2e7ac', 'Artist', 'Artist');
        INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist', 1);

        INSERT INTO release_group (id, gid, name, artist_credit)
            VALUES (1, '14928cab-363c-4457-951e-9b1c3ca404cd', 'Release', 1);

        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, 'a2d13b15-4002-4d04-8a08-b9a9a7fbe9ad', 'Release', 1, 1);

        INSERT INTO release_country (release, country) VALUES (1, 13);
        SQL

    my $editor = $c->model('Editor')->get_by_id(1);
    $c->model('Editor')->update_privileges($editor, { location_editor => 1 });

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_AREA_MERGE,
        editor_id => 1,
        old_entities => [ { id => 13, name => 'Australia' } ],
        new_entity => { id => 81, name => 'Germany' }
    );

    is exception { $edit->accept }, undef;
};

1;
