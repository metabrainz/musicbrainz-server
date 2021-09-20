package t::MusicBrainz::Server::Controller::Work::Edit;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply ignore re );
use MusicBrainz::Server::Test qw( accept_edit capture_edits html_ok );
use HTTP::Request::Common;
use List::UtilsBy qw( sort_by );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

my @edits = capture_edits {
    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/edit');
    html_ok($mech->content);
    my $request = POST $mech->uri, [
        'edit-work.comment' => 'A comment!',
        'edit-work.type_id' => 26,
        'edit-work.name' => 'Another name',
        'edit-work.iswcs.0' => 'T-000.000.002-0'
    ];
    my $response = $mech->request($request);
} $c;

@edits = sort_by { $_->id } @edits;

ok($mech->success, 'POST request success');
ok($mech->uri =~ qr{/work/745c079d-374e-4436-9448-da92dedef3ce$}, 'redirected to correct work page');
html_ok($mech->content);

my $edit = $edits[0];
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');
cmp_deeply($edit->data, {
    entity => {
        id => 1,
        gid => re('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
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
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content);
$mech->text_contains('Another name', '..has new name');
$mech->text_contains('Dancing Queen', '..has old name');
$mech->text_contains('Beijing opera', '..has new work type');
$mech->text_contains('Aria', '..has old work type');
$mech->text_contains('A comment!', '..has new comment');

$edit = $edits[1];
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddISWCs', 'adds ISWCs');
is_deeply($edit->data, {
    iswcs => [ {
        iswc => 'T-000.000.002-0',
        work => {
            id => 1,
            name => 'Dancing Queen'
        }
    } ]
}, 'add ISWC data looks correct');

$edit = $edits[2];
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::RemoveISWC', 'also removes ISWCs');
my @iswc = $c->model('ISWC')->find_by_iswc('T-000.000.001-0');

is_deeply($edit->data, {
    iswc => {
        id => $iswc[0]->id,
        iswc => 'T-000.000.001-0',
    },
    work => {
        id => 1,
        name => 'Dancing Queen'
    }
}, 'remove ISWC data looks correct');

};

test 'Editing works with attributes' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    $c->sql->do(<<~'SQL');
        -- We aren't interested in ISWC editing
        DELETE FROM iswc;
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/edit');
        html_ok($mech->content);
        my $request = POST $mech->uri, [
            'edit-work.name' => 'Work name',
            'edit-work.attributes.0.type_id' => 6,
            'edit-work.attributes.0.value' => 'Free text',
            'edit-work.attributes.1.type_id' => 1,
            'edit-work.attributes.1.value' => '13'
        ];
        my $response = $mech->request($request);
    } $c;

    is(@edits, 1, 'An edit was created');
    is_deeply(
        $edits[0]->data->{new}{attributes},
        [
            {
                attribute_text => 'Free text',
                attribute_type_id => 6,
                attribute_value_id => undef
            },
            {
                attribute_text => undef,
                attribute_type_id => 1,
                attribute_value_id => 13
            }
        ]
    );
};

test 'MBS-8636: Adding a relationship to a series which contains duplicate items' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-8636');

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'foo@example.com', now());
        SQL

    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'editor', password => 'pass' });

    my @edits = capture_edits {
        $mech->post('/work/02bfb89e-8877-47c0-a19d-b574bae78198/edit', {
            'edit-work.comment' => '',
            'edit-work.edit_note' => '',
            'edit-work.iswcs.0' => '',
            'edit-work.languages.0' => '486',
            'edit-work.name' => 'Concerto and Fugue in C minor, BWV 909',
            'edit-work.rel.0.attributes.0.text_value' => 'BWV 909',
            'edit-work.rel.0.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
            'edit-work.rel.0.backward' => '1',
            'edit-work.rel.0.entity0_credit' => '',
            'edit-work.rel.0.entity1_credit' => '',
            'edit-work.rel.0.link_order' => '0',
            'edit-work.rel.0.link_type_id' => '743',
            'edit-work.rel.0.target' => 'd977f7fd-96c9-4e3e-83b5-eb484a9e6582',
            'edit-work.type_id' => '',
        });
    } $c;

    is(scalar @edits, 1);
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Create');

    my $relationships = $c->sql->select_list_of_hashes('SELECT * FROM l_series_work ORDER BY id');
    cmp_deeply($relationships, [
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
    ]);
};

test 'Editing works with multiple languages' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    $c->sql->do(<<~'SQL');
        -- We aren't interested in ISWC editing
        DELETE FROM iswc;
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my @edits = capture_edits {
        $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/edit');
        my $request = POST $mech->uri, [
            'edit-work.name' => 'Dancing Queen',
            'edit-work.languages.0' => '120',
            'edit-work.languages.1' => '145',
            'edit-work.languages.2' => '198',
        ];
        my $response = $mech->request($request);
    } $c;

    is(@edits, 1, 'An edit was created');
    accept_edit($c, $edits[0]);

    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce', 'Fetch the work page');
    my ($languages) = $mech->scrape_text_by_attr('class', 'lyrics-language');
    like($languages, qr/English/, '..has English');
    like($languages, qr/German/, '..has German');
    like($languages, qr/Japanese/, '..has Japanese');

    @edits = capture_edits {
        $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/edit');
        my $request = POST $mech->uri, [
            'edit-work.name' => 'Dancing Queen',
            'edit-work.languages.0' => '145',
        ];
        my $response = $mech->request($request);
    } $c;

    is(@edits, 1, 'An edit was created');
    accept_edit($c, $edits[0]);

    $mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce', 'Fetch the work page');
    ($languages) = $mech->scrape_text_by_attr('class', 'lyrics-language');
    unlike($languages, qr/English/, '..does not have English');
    like($languages, qr/German/, '..has German');
    unlike($languages, qr/Japanese/, '..does not have Japanese');
};

1;
