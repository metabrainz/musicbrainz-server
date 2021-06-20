package t::MusicBrainz::Server::Edit::Series::Merge;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Series::Merge; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_SERIES_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    my $edit = create_merge_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Merge');

    my ($edits, $hits) = $c->model('Edit')->find({ series => [1, 3] }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    my $l1 = $c->model('Series')->get_by_id(1);
    my $l2 = $c->model('Series')->get_by_id(3);
    is($l1->edits_pending, 1);
    is($l2->edits_pending, 1);

    reject_edit($c, $edit);

    $l1 = $c->model('Series')->get_by_id(1);
    $l2 = $c->model('Series')->get_by_id(3);

    is($l1->edits_pending, 0);
    is($l2->edits_pending, 0);

    $c->model('SeriesType')->load($l1, $l2);

    (my $items, $hits) = $c->model('Series')->get_entities($l1);

    my @recordings = map +{
        gid => $_->{entity}->gid, text_value => $_->{ordering_key}
    }, @$items;

    is_deeply(\@recordings, [
        { gid => '123c079d-374e-4436-9448-da92dedef3ce', text_value => 'A1' },
        { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', text_value => 'A11' },
    ]);

    ($items, $hits) = $c->model('Series')->get_entities($l2);

    @recordings = map +{
        gid => $_->{entity}->gid, text_value => $_->{ordering_key}
    }, @$items;

    is_deeply(\@recordings, [
        { gid => '659f405b-b4ee-4033-868a-0daa27784b89', text_value => 'A10' },
        { gid => 'ae674299-2824-4500-9516-653ac1bc6f80', text_value => 'A100' },
    ]);

    $edit = create_merge_edit($c);
    accept_edit($c, $edit);

    $l1 = $c->model('Series')->get_by_id(1);
    $l2 = $c->model('Series')->get_by_id(3);

    ok(defined $l1);
    ok(!defined $l2);
    is($l1->edits_pending, 0);

    $c->model('SeriesType')->load($l1);

    ($items, $hits) = $c->model('Series')->get_entities($l1);

    @recordings = map +{
        gid => $_->{entity}->gid, text_value => $_->{ordering_key}
    }, @$items;

    is_deeply(\@recordings, [
        { gid => '123c079d-374e-4436-9448-da92dedef3ce', text_value => 'A1' },
        { gid => '659f405b-b4ee-4033-868a-0daa27784b89', text_value => 'A10' },
        { gid => '54b9d183-7dab-42ba-94a3-7388a66604b8', text_value => 'A11' },
        { gid => 'ae674299-2824-4500-9516-653ac1bc6f80', text_value => 'A100' },
    ]);
};

test 'Can merge series with editors subscribed at both ends' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');
    $c->sql->do(<<~'EOSQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (10, 'Fred', '{CLEARTEXT}mb', '', '', now());

        INSERT INTO edit (id, editor, type, status, expire_time)
            VALUES (1, 10, 1, 1, now());
        INSERT INTO edit_data (edit, data) VALUES (1, '{}');

        INSERT INTO editor_subscribe_series (editor, series, last_edit_sent)
            VALUES (10, 1, 1), (10, 3, 1);

        ALTER SEQUENCE edit_id_seq RESTART 2;
        EOSQL

    my $edit = create_merge_edit($c);
    $edit->accept;

    my $series = $c->model('Series')->get_by_id(1);
    my @editors = $c->model('Series')->subscription->find_subscribed_editors(1);

    is(@editors, 1, '1 subscribed editor');
    is($editors[0]->id, 10, 'Editor #10 is subscribed');

    @editors = $c->model('Series')->subscription->find_subscribed_editors(3);
    is(@editors, 0, 'No editors subscribed to series #3 (now merged)');
};

sub create_merge_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_SERIES_MERGE,
        editor_id => 1,
        old_entities => [ { id => 3, name => 'Dumb Recording Series' } ],
        new_entity => { id => 1, name => 'Test Recording Series' },
    );
}

1;
