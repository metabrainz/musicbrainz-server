package t::MusicBrainz::Server::Edit::Label::Merge;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Merge; }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');

my ($edits, $hits) = $c->model('Edit')->find({ label => [2, 3] }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $l1 = $c->model('Label')->get_by_id(2);
my $l2 = $c->model('Label')->get_by_id(3);
is($l1->edits_pending, 1);
is($l2->edits_pending, 1);

reject_edit($c, $edit);

$l1 = $c->model('Label')->get_by_id(2);
$l2 = $c->model('Label')->get_by_id(3);
is($l1->edits_pending, 0);
is($l2->edits_pending, 0);

$edit = create_edit($c);
accept_edit($c, $edit);

$l1 = $c->model('Label')->get_by_id(2);
$l2 = $c->model('Label')->get_by_id(3);
ok(!defined $l1);
ok(defined $l2);

is($l2->edits_pending, 0);

my $ipi_codes = $c->model('Label')->ipi->find_by_entity_id($l2->id);
is(scalar @$ipi_codes, 1, "Merged Label has all ipi codes after accepting edit");

my $isni_codes = $c->model('Label')->isni->find_by_entity_id($l2->id);
is(scalar @$isni_codes, 1, "Merged Label has all isni codes after accepting edit");

};

test 'Can merge labels with editors subscribed at both ends' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');
    $c->sql->do(<<~'EOSQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (10, 'Fred', '{CLEARTEXT}mb', '', '', now());

        INSERT INTO edit (id, editor, type, status, expire_time)
            VALUES (1, 10, 1, 1, now());
        INSERT INTO edit_data (edit, data) VALUES (1, '{}');

        INSERT INTO editor_subscribe_label (editor, label, last_edit_sent)
            VALUES (10, 2, 1), (10, 3, 1);

        ALTER SEQUENCE edit_id_seq RESTART 2;
        EOSQL

    my $edit = create_edit($c);
    $edit->accept;

    my $label = $c->model('Label')->get_by_id(3);
    my @editors = $c->model('Label')->subscription->find_subscribed_editors(3);

    is(@editors, 1, '1 subscribed editor');
    is($editors[0]->id, 10, 'Editor #10 is subscribed');

    @editors = $c->model('Label')->subscription->find_subscribed_editors(2);
    is(@editors, 0, 'No editors subscribed to label #2 (now merged)');
};

test 'Duplicate release labels are merged' => sub {
    my ($test) = @_;

    my $c = $test->c;
    my $release;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release_label');
    $c->sql->do("INSERT INTO release_label (release, label, catalog_number)
                 SELECT 1, label, catalog_number FROM release_label
                 WHERE release = 1");

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_MERGE,
        editor_id => 1,
        old_entities => [ { id => 3, name => 'Label 3' } ],
        new_entity => { id => 2, name => 'Label 2' },
    );

    $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    is($release->all_labels, 2, 'Two release labels before merge');

    $edit->accept;

    $release = $c->model('Release')->get_by_id(1);
    $c->model('ReleaseLabel')->load($release);
    is($release->all_labels, 1, 'One release label after merge');
};

sub create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_MERGE,
        editor_id => 1,
        old_entities => [ { id => 2, name => 'Old Artist' } ],
        new_entity => { id => 3, name => 'Old Label' },
    );
}

1;
