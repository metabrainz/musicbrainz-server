#!/usr/bin/perl
use strict;
use Test::More;

BEGIN {
    use MusicBrainz::Server::Test qw( xml_ok );
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_raw_test_database($c, "
    TRUNCATE artist_tag_raw CASCADE;
    TRUNCATE artist_rating_raw CASCADE;
    INSERT INTO artist_tag_raw (artist, editor, tag) VALUES (3, 1, 1), (3, 2, 1);
    INSERT INTO artist_rating_raw (artist, editor, rating)
        VALUES (8, 1, 4);
");
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/artist/745c079d-374e-4436-9448-da92dedef3ce", 'fetch artist index page');
xml_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has artist name');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/Artist, Test/, 'content has artist sort name');
$mech->content_like(qr/Yet Another Test Artist/, 'disambiguation comments');
$mech->content_like(qr/2008-01-02/, 'has start date');
$mech->content_like(qr/2009-03-04/, 'has end date');
$mech->content_like(qr/Person/, 'has artist type');
$mech->content_like(qr/Male/, 'has gender');
$mech->content_like(qr/United Kingdom/, 'has country');
$mech->content_like(qr/Test annotation 1/, 'has annotation');
$mech->content_unlike(qr/More annotation/, 'only display summary');

$mech->content_like(qr/Rating:.*?3\.5<\/span>/s);
$mech->content_like(qr/Show user ratings/);
$mech->content_like(qr/Last updated on 2009-07-09/);

# Header links
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/works', 'link to artist works');
$mech->content_contains('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'link to artist recordings');

# Basic test for release groups
$mech->content_like(qr/Test RG 1/, 'release group 1');
$mech->content_like(qr{/release-group/ecc33260-454c-11de-8a39-0800200c9a66}, 'release group 1');

$mech->content_like(qr/Test RG 2/, 'release group 2');
$mech->content_like(qr{/release-group/7348f3a0-454e-11de-8a39-0800200c9a66}, 'release group 2');

# Test /artist/gid/works
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/works', 'get ABBA page');
xml_ok($mech->content);
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/works/i, 'title indicates works listing');
$mech->content_contains('Dancing Queen');
$mech->content_contains('/work/745c079d-374e-4436-9448-da92dedef3ce', 'has a link to the work');

# Test /artist/gid/recordings
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/recordings', 'get ABBA page');
xml_ok($mech->content);
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/recordings/i, 'title indicates recordings listing');
$mech->content_contains('Dancing Queen');
$mech->content_contains('2:03');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'has a link to the recording');

# Test /artist/gid/releases
$mech->get_ok('/artist/a45c079d-374e-4436-9448-da92dedef3cf/releases', 'get ABBA page');
xml_ok($mech->content);
$mech->title_like(qr/ABBA/, 'title has ABBA');
$mech->title_like(qr/releases/i, 'title indicates releases listing');
$mech->content_contains('Arrival', 'release title');
$mech->content_contains('2009-05-08', 'release date');
$mech->content_contains('/release/f34c079d-374e-4436-9448-da92dedef3ce', 'has a link to the release');

# Test aliases
$mech->get_ok('/artist/945c079d-374e-4436-9448-da92dedef3cf/aliases', 'get artist aliases');
xml_ok($mech->content);
$mech->content_contains('Test Alias', 'has the artist alias');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce', 'get artist aliases');
xml_ok($mech->content);
$mech->content_unlike(qr/Test Alias/, 'other artist pages do not have the alias');

# Test relationships
$mech->get_ok('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/relationships', 'get artist relationships');
xml_ok($mech->content);
$mech->content_contains('performed guitar');
$mech->content_contains('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8');

# Test tags
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
xml_ok($mech->content);
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}), 'link to the "musical" tag');

# Test ratings
$mech->get_ok('/artist/e2a083a9-9942-4d6e-b4d2-8397320b95f7/ratings', 'get artist ratings');
xml_ok($mech->content);
$mech->content_contains('new_editor');
$mech->content_contains('4 - ');

# Test creating new artists via the create artist form
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/artist/create');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'controller artist',
        'edit-artist.sort_name' => 'artist, controller',
        'edit-artist.type_id' => 1,
        'edit-artist.country_id' => 2,
        'edit-artist.gender_id' => 2,
        'edit-artist.begin_date.year' => 1990,
        'edit-artist.begin_date.month' => 01,
        'edit-artist.begin_date.day' => 02,
        'edit-artist.end_date.year' => 2003,
        'edit-artist.end_date.month' => 4,
        'edit-artist.end_date.day' => 15,
        'edit-artist.comment' => 'artist created in controller_artist.t',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/artist/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})}, 'should redirect to artist page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
is_deeply($edit->data, {
        name => 'controller artist',
        sort_name => 'artist, controller',
        type_id => 1,
        country_id => 2,
        gender_id => 2,
        comment => 'artist created in controller_artist.t',
        begin_date => {
            year => 1990,
            month => 01,
            day => 02
        },
        end_date => {
            year => 2003,
            month => 4,
            day => 15
        },
    });

# Test editing artists
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-artist.name' => 'edit artist',
        'edit-artist.sort_name' => 'artist, controller',
        'edit-artist.type_id' => '',
        'edit-artist.country_id' => 2,
        'edit-artist.gender_id' => 2,
        'edit-artist.begin_date.year' => 1990,
        'edit-artist.begin_date.month' => 01,
        'edit-artist.begin_date.day' => 02,
        'edit-artist.end_date.year' => '',
        'edit-artist.end_date.month' => '',
        'edit-artist.end_date.day' => '',
        'edit-artist.comment' => 'artist created in controller_artist.t',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/artist/745c079d-374e-4436-9448-da92dedef3ce}, 'should redirect to artist page via gid');

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');
is_deeply($edit->data, {
        artist => 3,
        new => {
            name => 'edit artist',
            sort_name => 'artist, controller',
            type_id => undef,
            country_id => 2,
            gender_id => 2,
            comment => 'artist created in controller_artist.t',
            begin_date => {
                year => 1990,
                month => 01,
                day => 02
            },
            end_date => undef,
        },
        old => {
            name => 'Test Artist',
            sort_name => 'Artist, Test',
            type_id => 1,
            gender_id => 1,
            country_id => 1,
            comment => 'Yet Another Test Artist',
            begin_date => {
                year => 2008,
                month => 1,
                day => 2
            },
            end_date => {
                year => 2009,
                month => 3,
                day => 4
            },
        }
    });

# Test deleting artists via the website
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/delete');
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Delete');
is_deeply($edit->data, { artist_id => 3 });

# Test merging artists
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/merge');
xml_ok($mech->content);
$response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'David',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'results.selected_id' => 5
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/artist/5441c29d-3602-4898-b1a1-b77fa23b8e50});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');
is_deeply($edit->data, {
        old_artist => 3,
        new_artist => 5,
    });


# Test tagging
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tag');
xml_ok($mech->content);
$response = $mech->submit_form(
    with_fields => {
        'tag.tags' => 'World Music, Jazz',
    }
);
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/tags');
xml_ok($mech->content);
$mech->content_contains('world music');
$mech->content_contains('jazz');

# Test adding annotations
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => 'This is my annotation',
        'edit-annotation.changelog' => 'Changelog here',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAnnotation');
is_deeply($edit->data, {
    entity_id => 3,
    text => 'This is my annotation',
    changelog => 'Changelog here',
    editor_id => 1
});

done_testing;
