package t::MusicBrainz::Server::Edit::Artist::Create;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Create }

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_CREATE
    $STATUS_APPLIED
    $STATUS_FAILEDVOTE
    $STATUS_OPEN
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Test qw( reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        SET client_min_messages TO warning;
        TRUNCATE artist CASCADE;
        SQL

    # avoid artist_va_check violation
    $c->sql->do(q(SELECT setval('artist_id_seq', 1)));

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_CREATE,
        name => 'Junior Boys',
        gender_id => 1,
        comment => 'Canadian electronica duo',
        editor_id => 1,
        begin_date => { 'year' => 1981, 'month' => 5 },
        ended => 1,
        ipi_codes => [],
        isni_codes => [],
    );
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');

    ok(defined $edit->artist_id, 'edit should store the artist id');

    my ($edits, undef) = $c->model('Edit')->find({ artist => $edit->artist_id }, 10, 0);
    is($edits->[0]->id, $edit->id, 'Edit IDs match between edit and ->find');

    my $artist = $c->model('Artist')->get_by_id($edit->artist_id);
    ok(defined $artist, 'Artist was actually created.');
    is($artist->name, 'Junior Boys', 'Name is correct in created artist.');
    is($artist->gender_id, 1, 'Gender ID is correct in created artist.');
    is($artist->comment, 'Canadian electronica duo', 'Comment is correct in created artist.');
    is($artist->begin_date->format, '1981-05', 'Begin date is correct in created artist.');
    is($artist->ended, 1, 'Has "ended" set on created artist.');

    my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id($artist->id);
    is(scalar @$ipi_codes, 0, 'Artist has no ipi codes');

    my $isni_codes = $c->model('Artist')->isni->find_by_entity_id($artist->id);
    is(scalar @$isni_codes, 0, 'Artist has no isni codes');

    $edit = $c->model('Edit')->get_by_id($edit->id);
    $c->model('Edit')->load_all($edit);

    is($edit->display_data->{name}, 'Junior Boys', 'Name is correct in display data.');
    is($edit->display_data->{gender}->{name}, 'Male', 'Gender is correct in display data.');
    is($edit->display_data->{comment}, 'Canadian electronica duo', 'Comment is correct in display data.');
    is($edit->display_data->{begin_date}{year}, 1981, 'Begin date is correct in display data.' );
    is($edit->display_data->{ended}, boolean_to_json(1), 'Has "ended" set in display data.');

    is($edit->status, $STATUS_APPLIED, 'add artist edits should be autoedits');
    is($artist->edits_pending, 0, 'add artist edits should be autoedits');
};

test 'Uniqueness violations are caught before insertion (MBS-6065)' => sub {
    my ($test) = @_;

    my $c = $test->c;

    $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_CREATE,
        editor_id => 1,
        name => 'I am a dupe without a comment',
        comment => '',
        ipi_codes => [],
        isni_codes => []
    );

    is(exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_ARTIST_CREATE,
            editor_id => 1,
            name => 'I am a dupe without a comment',
            comment => '',
            ipi_codes => [],
            isni_codes => []
        );
    }, 'A disambiguation comment is required for this entity.');

    $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_CREATE,
        editor_id => 1,
        name => 'I am a dupe with a comment',
        comment => 'a comment',
        ipi_codes => [],
        isni_codes => []
    );

    is(exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_ARTIST_CREATE,
            editor_id => 1,
            name => 'I am a dupe with a comment',
            comment => 'a comment',
            ipi_codes => [],
            isni_codes => []
        );
    }, 'The given values duplicate an existing row.');
};

test 'Rejecting an "Add artist" edit where the artist has subscriptions (MBS-8690)' => sub {
    my ($test) = @_;

    my $c = $test->c;

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_CREATE,
        editor_id => 1,
        name => 'Artist',
        comment => '',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is($edit->status, $STATUS_OPEN);
    $c->model('Artist')->subscription->subscribe(1, $edit->artist_id);
    reject_edit($c, $edit);
    is($edit->status, $STATUS_FAILEDVOTE);
};

1;
