#!/usr/bin/perl
use strict;
use Test::More;
use HTTP::Request::Common;

BEGIN {
    use MusicBrainz::Server::Test qw( xml_ok );
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login', 'login');
xml_ok($mech->content, '...valid xml');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit sidebar attributes');
xml_ok($mech->content, '...valid');

# Test editing side bar attributes
my $request = POST $mech->uri, [
    'edit-release.date.year' => '2009',
    'edit-release.date.month' => '10',
    'edit-release.date.day' => '25',
    'edit-release.packaging_id' => '2',
    'edit-release.status_id', '2',
    'edit-release.language_id' => '2',
    'edit-release.script_id' => '2',
    'edit-release.country_id' => '2',
    'edit-release.barcode' => '9780596001087',
];

my $response = $mech->request($request);
ok($mech->success, '...post an edit request');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit', '...edit isa edit-release edit');
is_deeply($edit->data, {
    release => 2,
    new => {
        date => {
             year => 2009,
             month => 10,
             day => 25
        },
        packaging_id => 2,
        status_id => 2,
        language_id => 2,
        script_id => 2,
        country_id => 2,
        barcode => '9780596001087',
    },
    old => {
        date => {
             year => 2005,
             month => 11,
             day => 7
        },
        packaging_id => undef,
        status_id => 1,
        language_id => undef,
        script_id => undef,
        country_id => 1,
        barcode => '0094634396028',
    }
}, '...edit has the correct data');

# Test editing stuff in the "header"
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit header details');
my $request = POST $mech->uri, [
    'edit-release.artist_credit.names.0.name' => 'Bob Marley',
    'edit-release.artist_credit.names.0.artist_id' => 4,
    'edit-release.name' => 'A new name',
    'edit-release.comment' => 'With a fancy comment',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Edit', '...edit is a edit-release edit');
is_deeply($edit->data, {
    release => 2,
    new => {
        artist_credit => [
        { name => 'Bob Marley', artist => 4 }
        ],
        name => 'A new name',
        comment => 'With a fancy comment',
    },
    old => {
        comment => undef,
        name => 'Aerial',
        artist_credit => [
        { name => 'Kate Bush', artist => 7 }
        ]
    }
}, '...edit has the right data');

# Editing tracks in a tracklist
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit tracklist tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '3',
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'Renamed track',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.artist_id' => '5',
    'edit-release.mediums.0.tracklist.tracks.0.id' => '4',
    'edit-release.mediums.0.tracklist.tracks.0.length' => '4:20',
    'edit-release.mediums.0.tracklist.tracks.0.position' => '4',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Track::Edit', '...edit is a edit-track edit');
is_deeply($edit->data, {
    track => 4,
    new => {
        name => 'Renamed track',
        artist_credit => [
        { name => 'The Edit Ninja', artist => 5 }
        ],
        position => 4,
    },
    old => {
        name => 'King of the Mountain',
        artist_credit => [
        { name => 'Kate Bush', artist => 7 }
        ],
        position => 1
    }
}, '...edit has the right data');

TODO: {
    local $TODO = 'Support editing the length of tracks';
    ok(exists $edit->data->{new}->{length});
    ok(exists $edit->data->{old}->{length});
}

# Deleting tracks
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'deleting tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '3',
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'Renamed track',
    'edit-release.mediums.0.tracklist.tracks.0.id' => '4',
    'edit-release.mediums.0.tracklist.tracks.0.deleted' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::DeleteTrack', '...edit is a delete-track edit');
is_deeply($edit->data, {
    track_id => 4,
}, '...edit has the right data');

# Adding new tracks
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new tracks');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.tracklist.id' => '3',
    'edit-release.mediums.0.tracklist.tracks.0.name' => 'New track',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.0.tracklist.tracks.0.artist_credit.names.0.artist_id' => '5',
    'edit-release.mediums.0.tracklist.tracks.0.length' => '4:20',
    'edit-release.mediums.0.tracklist.tracks.0.position' => '4',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::AddTrack', '...edit is a add-track edit');
is_deeply($edit->data, {
    tracklist_id => 3,
    name => 'New track',
    artist_credit => [
    { artist => 5, name => 'The Edit Ninja' }
    ],
    position => 4
}, '...edit has the right data');

# Adding new mediums with existing tracklists
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new mediums (existing tracklist)');
my $request = POST $mech->uri, [
    'edit-release.mediums.2.name' => 'Unreleased Hits',
    'edit-release.mediums.2.tracklist.id' => '2',
    'edit-release.mediums.2.format_id' => '2',
    'edit-release.mediums.2.medium' => '3',
    'edit-release.mediums.2.position' => '3',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create', '...edit isa a create-medium edit');
is_deeply($edit->data, {
    release_id => 2,
    position => 3,
    tracklist_id => 2,
    format_id => 2,
    name => 'Unreleased Hits',
}, '...edit has the right data');

# Deleting mediums
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'deleting mediums');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.id' => '3',
    'edit-release.mediums.0.deleted' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Delete', '...edit is a delete-medium edit');
is_deeply($edit->data, {
    medium_id => 3,
}, '...edit has the right data');

# Editing mediums
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'edit existing mediums');
my $request = POST $mech->uri, [
    'edit-release.mediums.0.id' => '3',
    'edit-release.mediums.0.name' => 'Renamed Medium',
    'edit-release.mediums.0.format_id' => '2',
    'edit-release.mediums.0.position' => 2,
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Edit', '...edit is a edit-medium edit');
is_deeply($edit->data, {
    medium => 3,
    new => {
        name => 'Renamed Medium',
        format_id => 2,
        position => 2,
    },
    old => {
        name => 'A Sea of Honey',
        format_id => 1,
        position => 1
    }
}, '...edit has the right data');

# New medium, new tracklist
$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/edit', 'adding new mediums (existing tracklist)');
my $request = POST $mech->uri, [
    'edit-release.mediums.2.name' => 'Unreleased Hits',
    'edit-release.mediums.2.format_id' => '2',
    'edit-release.mediums.2.medium' => '3',
    'edit-release.mediums.2.position' => '4',
    'edit-release.mediums.2.tracklist.tracks.0.name' => 'New track',
    'edit-release.mediums.2.tracklist.tracks.0.artist_credit.names.0.name' => 'The Edit Ninja',
    'edit-release.mediums.2.tracklist.tracks.0.artist_credit.names.0.artist_id' => '5',
    'edit-release.mediums.2.tracklist.tracks.0.length' => '1:59',
    'edit-release.mediums.2.tracklist.tracks.0.position' => '1',
];

my $response = $mech->request($request);
ok($mech->success, '...submit edit');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::Create', '...edit isa a create-medium edit');
is($edit->data->{release_id}, 2, '...edit has the right data');
is($edit->data->{position}, 4, '...edit has the right data');
is($edit->data->{format_id}, 2, '...edit has the right data');
is($edit->data->{name}, 'Unreleased Hits', '...edit has the right data');
ok($edit->data->{tracklist_id}, '...edit has the right data');

done_testing;
