package t::MusicBrainz::Server::Controller::Recording::Edit;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply re );
use MusicBrainz::Server::Test qw( capture_edits html_ok );
use HTTP::Request::Common;
use List::AllUtils qw( sort_by );

with 't::Edit';
with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

$c->sql->do(<<~'SQL');
    INSERT INTO artist (id, gid, name, sort_name, comment)
        VALUES (3, '745c079d-374e-4436-9448-da92dedef3ce', 'ABBA', 'ABBA', 'A'),
               (6, 'a45c079d-374e-4436-9448-da92dedef3cf', 'ABBA', 'ABBA', 'B'),
               (4, '945c079d-374e-4436-9448-da92dedef3cf', 'ABBA', 'ABBA', 'C'),
               (5, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'ABBA', 'ABBA', 'D');

    INSERT INTO artist_credit (id, name, artist_count, gid)
        VALUES (1, 'ABBA', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
    INSERT INTO artist_credit_name (artist_credit, position, artist, name)
        VALUES (1, 0, 6, 'ABBA');
    INSERT INTO recording (id, gid, name, artist_credit, length)
        VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'Dancing Queen', 1, 123456);
    INSERT INTO isrc (isrc, recording) VALUES ('DEE250800231', 1);
    SQL

$mech->get_ok('/login');
$mech->submit_form(
    with_fields => { username => 'editor', password => 'pass' } );

my @edits = capture_edits {
    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edit');
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

    $mech->request($request);
} $c;

@edits = sort_by { $_->id } @edits;

ok($mech->success);
like($mech->uri, qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8$});
html_ok($mech->content);

my $edit = $edits[0];
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');
cmp_deeply($edit->data, {
    entity => {
        id => 1,
        gid => re('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
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
html_ok($mech->content);
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


# test edit-recording submission without artist credit fields

@edits = capture_edits {
    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edit');
    html_ok($mech->content);
    my $request = POST $mech->uri, [
        'edit-recording.length' => '4:56',
        'edit-recording.name' => 'Dancing Queen'
    ];

    $mech->request($request);
} $c;

@edits = sort_by { $_->id } @edits;

ok($mech->success);
ok($mech->uri =~ qr{/recording/54b9d183-7dab-42ba-94a3-7388a66604b8$});
html_ok($mech->content);

$edit = $edits[0];
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::Edit');
cmp_deeply($edit->data, {
    entity => {
        id => 1,
        gid => re('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
        name => 'Dancing Queen'
    },
    new => { length => 296000 },
    old => { length => 123456 }
});

};

1;
