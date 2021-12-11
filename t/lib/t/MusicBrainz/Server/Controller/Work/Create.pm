package t::MusicBrainz::Server::Controller::Work::Create;
use Test::Routine;
use Test::More;
use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use List::AllUtils qw( nsort_by );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

my @edits = capture_edits {
    $mech->get_ok('/work/create');
    html_ok($mech->content);

    my $request = POST $mech->uri, [
        'edit-work.comment' => 'A comment!',
        'edit-work.type_id' => 26,
        'edit-work.name' => 'Enchanted',
        'edit-work.iswcs.0' => 'T-000.000.003-0',
        'edit-work.iswcs.1' => 'T-000.000.004-0',
        'edit-work.languages.0' => '120',
        'edit-work.languages.1' => '134',
    ];

    $mech->request($request);
} $c;

@edits = nsort_by { $_->id } @edits;

ok($mech->success);

my $edit = $edits[0];
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Create');
is_deeply($edit->data, {
    name          => 'Enchanted',
    comment       => 'A comment!',
    type_id       => 26,
    attributes    => [],
    languages     => [120, 134],
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content);
my ($details) = $mech->scrape_text_by_attr('class', 'details add-work');
like($details, qr/Enchanted/, '..has work name');
like($details, qr/A comment!/, '..has comment');
like($details, qr/Beijing opera/, '..has type');
like($details, qr/English, French/, '..has languages');

$edit = $edits[1];
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddISWCs');
is_deeply($edit->data, {
    iswcs => [
        {
            iswc => 'T-000.000.003-0',
            work => {
                id => $edits[0]->entity_id,
                name => 'Enchanted'
            }
        },
        {
            iswc => 'T-000.000.004-0',
            work => {
                id => $edits[0]->entity_id,
                name => 'Enchanted'
            }
        },
    ]
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content);
($details) = $mech->scrape_text_by_attr('class', 'details add-iswcs');
like($details, qr/T-000\.000\.003-0/, '..has ISWC 1');
like($details, qr/T-000\.000\.004-0/, '..has ISWC 2');

};

1;
