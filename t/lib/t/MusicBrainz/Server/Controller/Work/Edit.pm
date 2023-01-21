package t::MusicBrainz::Server::Controller::Work::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply ignore );
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( accept_edit capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic work editing works, and specifically tests
work attributes and languages. It also ensures a work can be added to a series
that already contains duplicate items, which used to ISE (MBS-8636).

=cut

test 'Editing a work' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the work editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-work.comment' => 'A comment!',
                'edit-work.type_id' => 26,
                'edit-work.name' => 'Another name',
                'edit-work.iswcs.0' => 'T-000.000.002-0'
            },
            'The form returned a 2xx response code',
        );
    } $c;

    ok(
        $mech->uri =~ qr{/work/745c079d-374e-4436-9448-da92dedef3ce$},
        'The user is redirected to the work page after entering the edit',
    );

    is(@edits, 3, 'Three edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Work::Edit');

    is_deeply(
        $edits[0]->data,
        {
            entity => {
                id => 1,
                gid => '745c079d-374e-4436-9448-da92dedef3ce',
                name => 'Dancing Queen'
            },
            new => {
                name => 'Another name',
                type_id => 26,
                comment => 'A comment!',
            },
            old => {
                type_id => 1,
                comment => '',
                name => 'Dancing Queen'
            },
        },
        'The edit work edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok(
        '/edit/' . $edits[0]->id,
        'Fetched the edit work edit page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Dancing Queen',
        'The edit page contains the old work name',
    );
    $mech->text_contains(
        'Another name',
        'The edit page contains the new work name',
    );
    $mech->text_contains(
        'Aria',
        'The edit page contains the old work type',
    );
    $mech->text_contains(
        'Beijing opera',
        'The edit page contains the new work type',
    );
    $mech->text_contains(
        'A comment!',
        'The edit page contains the new disambiguation',
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Work::AddISWCs', 'adds ISWCs');

    is_deeply(
        $edits[1]->data,
        {
            iswcs => [ {
                iswc => 'T-000.000.002-0',
                work => {
                    id => 1,
                    name => 'Dancing Queen',
                },
            } ],
        },
        'The add ISWC edit contains the right data',
    );

    isa_ok($edits[2], 'MusicBrainz::Server::Edit::Work::RemoveISWC', 'also removes ISWCs');
    my @iswc = $c->model('ISWC')->find_by_iswc('T-000.000.001-0');

    is_deeply(
        $edits[2]->data,
        {
            iswc => {
                id => $iswc[0]->id,
                iswc => 'T-000.000.001-0',
            },
            work => {
                id => 1,
                name => 'Dancing Queen',
            },
        },
        'The remove ISWC edit contains the right data',
    );
};

test 'Editing work attributes' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    $c->sql->do(<<~'SQL');
        -- We aren't interested in ISWC editing
        DELETE FROM iswc;
        SQL

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the work editing page',
    );

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-work.name' => 'Dancing Queen',
                'edit-work.type_id' => 1,
                'edit-work.attributes.0.type_id' => 6,
                'edit-work.attributes.0.value' => 'Free text',
                'edit-work.attributes.1.type_id' => 1,
                'edit-work.attributes.1.value' => '13',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '745c079d-374e-4436-9448-da92dedef3ce',
                name => 'Dancing Queen'
            },
            new => {
                attributes => [
                    {
                        attribute_text => 'Free text',
                        attribute_type_id => 6,
                        attribute_value_id => undef,
                    },
                    {
                        attribute_text => undef,
                        attribute_type_id => 1,
                        attribute_value_id => 13,
                    },
                ],
            },
            old => {
                attributes => [],
            },
        },
        'The edit contains the right data',
    );
};

test 'Relationship can be added to series which contains duplicates (MBS-8636)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8636');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' }
    );

    my @edits = capture_edits {
        $mech->post_ok(
            '/work/02bfb89e-8877-47c0-a19d-b574bae78198/edit',
            {
                'edit-work.languages.0' => '486',
                'edit-work.name' => 'Concerto and Fugue in C minor, BWV 909',
                'edit-work.rel.0.attributes.0.text_value' => 'BWV 909',
                'edit-work.rel.0.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                'edit-work.rel.0.backward' => '1',
                'edit-work.rel.0.link_order' => '0',
                'edit-work.rel.0.link_type_id' => '743',
                'edit-work.rel.0.target' => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');

    is($edit->status, $STATUS_APPLIED, 'The edit was applied');

    my $relationships = $c->sql->select_list_of_hashes(
        'SELECT * FROM l_series_work ORDER BY id',
    );
    cmp_deeply(
        $relationships,
        [
            {
                edits_pending => 1,
                entity0 => 25,
                entity0_credit => '',
                entity1 => 10465539,
                entity1_credit => '',
                id => 2025,
                last_updated => ignore(),
                link => 170801,
                link_order => 749,
            },
            {
                edits_pending => 0,
                entity0 => 25,
                entity0_credit => '',
                entity1 => 10465539,
                entity1_credit => '',
                id => 15120,
                last_updated => ignore(),
                link => 170801,
                link_order => 2,
            },
            {
                edits_pending => 0,
                entity0 => 25,
                entity0_credit => '',
                entity1 => 12894254,
                entity1_credit => '',
                id => 15121,
                last_updated => ignore(),
                link => 170802,
                link_order => 1,
            },
        ],
        'The relationship data in the database is as expected',
    );
};

test 'Editing (multiple) work languages' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    $c->sql->do(<<~'SQL');
        -- We aren't interested in ISWC editing
        DELETE FROM iswc;
        SQL

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the work editing page',
    );

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-work.name' => 'Dancing Queen',
                'edit-work.type_id' => 1,
                'edit-work.languages.0' => '120',
                'edit-work.languages.1' => '145',
                'edit-work.languages.2' => '198',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '745c079d-374e-4436-9448-da92dedef3ce',
                name => 'Dancing Queen'
            },
            new => {
                languages => ['120', '145', '198'],
            },
            old => {
                languages => [],
            },
        },
        'The edit adding languages contains the right data',
    );

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce',
        'Fetched the work page',
    );
    my ($languages) = $mech->scrape_text_by_attr('class', 'lyrics-language');
    like($languages, qr/English/, 'The languages section lists English');
    like($languages, qr/German/, 'The languages section lists German');
    like($languages, qr/Japanese/, 'The languages section lists Japanese');

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce/edit',
        'Fetched the work editing page',
    );

    my @edits = capture_edits {
        $mech->post_ok(
            $mech->uri,
            {
                'edit-work.name' => 'Dancing Queen',
                'edit-work.type_id' => 1,
                'edit-work.languages.0' => '145',
            },
            'The form returned a 2xx response code',
        );
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '745c079d-374e-4436-9448-da92dedef3ce',
                name => 'Dancing Queen'
            },
            new => {
                languages => ['145'],
            },
            old => {
                languages => ['120', '145', '198'],
            },
        },
        'The edit removing some languages contains the right data',
    );

    accept_edit($c, $edit);

    $mech->get_ok(
        '/work/745c079d-374e-4436-9448-da92dedef3ce',
        'Fetched the work page again after accepting the new edit',
    );
    my ($languages) = $mech->scrape_text_by_attr('class', 'lyrics-language');
    unlike(
        $languages,
        qr/English/,
        'The languages section no longer lists English',
    );
    like($languages, qr/German/, 'The languages section still lists German');
    unlike(
        $languages,
        qr/Japanese/,
        'The languages section no longer lists Japanese',
    );
};

1;
