package t::MusicBrainz::Server::Controller::Recording::Edit;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );
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
    $mech->get_ok("/recording/123c079d-374e-4436-9448-da92dedef3ce/edit");
    html_ok($mech->content);
    my $request = POST $mech->uri, [
        'edit-recording.length' => '1:23',
        'edit-recording.comment' => 'A comment!',
        'edit-recording.name' => 'Another name',
        'edit-recording.artist_credit.names.0.name' => 'Foo',
        'edit-recording.artist_credit.names.0.artist.name' => 'Bar',
        'edit-recording.artist_credit.names.0.artist.id' => '3',
        'edit-recording.artist_credit.names.1.name' => '',
        'edit-recording.artist_credit.names.1.artist.name' => 'Queen',
        'edit-recording.artist_credit.names.1.artist.id' => '4',
        'edit-recording.artist_credit.names.2.name' => '',
        'edit-recording.artist_credit.names.2.artist.name' => 'David Bowie',
        'edit-recording.artist_credit.names.2.artist.id' => '5',
        'edit-recording.isrcs.0' => 'USS1Z9900001'
    ];

    my $response = $mech->request($request);
} $c;

@edits = sort_by { $_->id } @edits;

ok($mech->success);
ok($mech->uri =~ qr{/recording/123c079d-374e-4436-9448-da92dedef3ce$});
html_ok($mech->content);

my $edit = $edits[0];
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');
is_deeply($edit->data, {
    entity => {
        id => 1,
        name => 'Dancing Queen'
    },
    new => {
        artist_credit => {
            names => [
                {
                    artist => { id => 3, name => 'Bar' },
                    name => 'Foo',
                    join_phrase => ''
                },
                {
                    artist => { id => 4, name => 'Queen' },
                    name => 'Queen',
                    join_phrase => ''
                },
                {
                    artist => { id => 5, name => 'David Bowie' },
                    name => 'David Bowie',
                    join_phrase => ''
                }
            ],
        },
        name => 'Another name',
        comment => 'A comment!',
        length => 83000,
    },
    old => {
        artist_credit => {
            names => [
                {
                    artist => { id => 6, name => 'ABBA' },
                    name => 'ABBA',
                    join_phrase => '',
                }
            ],
        },
        name => 'Dancing Queen',
        comment => '',
        length => 123456,
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
html_ok($mech->content, '..valid xml');
$mech->text_contains('Another name', '..has new name');
$mech->text_contains('Dancing Queen', '..has old name');
$mech->text_contains('1:23', '..has new length');
$mech->text_contains('2:03', '..has old length');
$mech->text_contains('A comment!', '..has new comment');
$mech->text_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->text_contains('Queen', '..has new artist 2');
$mech->content_contains('/artist/945c079d-374e-4436-9448-da92dedef3cf', '...and links to artist 2');
$mech->text_contains('David Bowie', '..has new artist 3');
$mech->content_contains('/artist/5441c29d-3602-4898-b1a1-b77fa23b8e50', '...and links to artist 3');
$mech->text_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

$edit = $edits[1];
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs', 'adds ISRCs');
is_deeply($edit->data, {
    isrcs => [ {
        isrc => 'USS1Z9900001',
        recording => {
            id => 1,
            name => 'Dancing Queen'
        },
        source => 0,
    } ],
    client_version => JSON::null
}, 'add ISRC edit data is correct');
	
$edit = $edits[2];
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::RemoveISRC', 'also removes ISRCs');
my @isrc = $c->model('ISRC')->find_by_isrc('DEE250800231');
	
is_deeply($edit->data, {
    isrc => {
        id => $isrc[0]->id,
        isrc => 'DEE250800231',
    },
    recording => {
        id => 1,
        name => 'Dancing Queen'
    }
}, 'remove ISRC data is correct');

};

1;
