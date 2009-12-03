#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Request::Common;
use Test::More;

use MusicBrainz::Server::Test qw( xml_ok );
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce");
xml_ok($mech->content);
$mech->content_like(qr/Dancing Queen/, 'work title');
$mech->content_like(qr/ABBA/, 'artist credit');
$mech->content_like(qr/Composition/, 'work type');
$mech->content_like(qr{/work/745c079d-374e-4436-9448-da92dedef3ce}, 'link back to work');
$mech->content_like(qr{/artist/a45c079d-374e-4436-9448-da92dedef3cf}, 'link to ABBA');
$mech->content_like(qr/T-000.000.001-0/, 'iswc');
$mech->content_like(qr{Test annotation 6}, 'annotation');

# Missing
$mech->get('/work/dead079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

# Invalid UUID
$mech->get('/work/xxxx079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

# Test tags
$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/tags");
xml_ok($mech->content);
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}),
    'link to the "musical" tag');

# Test ratings
$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/ratings");
xml_ok($mech->content);

# Test editing the work
$mech->get_ok('/login');
xml_ok($mech->content);
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/edit");
xml_ok($mech->content);
my $request = POST $mech->uri, [
    'edit-work.iswc' => 'T-123456789-0',
    'edit-work.comment' => 'A comment!',
    'edit-work.type_id' => 2,
    'edit-work.name' => 'Another name',
    'edit-work.artist_credit.names.0.name' => 'Foo',
    'edit-work.artist_credit.names.0.artist_id' => '3',
];

my $response = $mech->request($request);
ok($mech->success);
ok($mech->uri =~ qr{/work/745c079d-374e-4436-9448-da92dedef3ce$});
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');
is_deeply($edit->data, {
    work => 1,
    new => {
        name => 'Another name',
        type_id => 2,
        comment => 'A comment!',
        iswc => 'T-123.456.789-0',
        artist_credit => [
        { artist => 3, name => 'Foo' }
        ]
    },
    old => {
        type_id => 1,
        comment => undef,
        iswc => 'T-000.000.001-0',
        name => 'Dancing Queen',
        artist_credit => [
        { artist => 6, name => 'ABBA' }
        ]
    }
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch the edit page');
xml_ok($mech->content, '..valid xml');
$mech->content_contains('Another name', '..has new name');
$mech->content_contains('Dancing Queen', '..has old name');
$mech->content_contains('T-123.456.789-0', '..has new iswc');
$mech->content_contains('T-000.000.001-0', '..has old iswc');
$mech->content_contains('Symphony', '..has new work type');
$mech->content_contains('Composition', '..has old work type');
$mech->content_contains('A comment!', '..has new comment');
$mech->content_contains('Foo', '..has new artist');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce', '...and links to artist');
$mech->content_contains('ABBA', '..has old artist');
$mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', '...and links to artist');

# Test adding annotations
$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation");
$mech->submit_form(
    with_fields => {
        'edit-annotation.text'      => 'This is my annotation',
        'edit-annotation.changelog' => 'Changelog here',
    }
);

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddAnnotation');
is_deeply(
    $edit->data,
    {
        entity_id => 1,
        text      => 'This is my annotation',
        changelog => 'Changelog here',
        editor_id => 1
    }
);

done_testing;
