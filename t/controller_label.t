#!/usr/bin/perl
use strict;
use Test::More;

BEGIN {
    use MusicBrainz::Server::Test qw( xml_ok );
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190", 'fetch label index');
xml_ok($mech->content);
$mech->title_like(qr/Warp Records/, 'title has label name');
$mech->content_like(qr/Warp Records/, 'content has label name');
$mech->content_like(qr/Sheffield based electronica label/, 'disambiguation comments');
$mech->content_like(qr/1989-02-03/, 'has start date');
$mech->content_like(qr/2008-05-19/, 'has end date');
$mech->content_like(qr/United Kingdom/, 'has country');
$mech->content_like(qr/Production/, 'has label type');
$mech->content_like(qr/Test annotation 2/, 'has annotation');

# Check releases
$mech->content_like(qr/Arrival/, 'has release title');
$mech->content_like(qr/ABC-123/, 'has catalog of first release');
$mech->content_like(qr/ABC-123-X/, 'has catalog of second release');
$mech->content_like(qr/2009-05-08/, 'has release date');
$mech->content_like(qr{GB}, 'has country in release list');
$mech->content_like(qr{/release/f34c079d-374e-4436-9448-da92dedef3ce}, 'links to correct release');

# Test aliases
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/aliases', 'get label aliases');
xml_ok($mech->content);
$mech->content_contains('Test Label Alias', 'has the label alias');

# Test tags
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/tags');
xml_ok($mech->content);
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}), 'link to the "musical" tag');

# Test ratings
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/ratings', 'get label ratings');
xml_ok($mech->content);

# Test creating new artists via the create artist form
$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/label/create');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-label.name' => 'controller label',
        'edit-label.sort_name' => 'label, controller',
        'edit-label.type_id' => 2,
        'edit-label.label_code' => 12345,
        'edit-label.country_id' => 1,
        'edit-label.begin_date.year' => 1990,
        'edit-label.begin_date.month' => 01,
        'edit-label.begin_date.day' => 02,
        'edit-label.end_date.year' => 2003,
        'edit-label.end_date.month' => 4,
        'edit-label.end_date.day' => 15,
        'edit-label.comment' => 'label created in controller_label.t',
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/label/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})}, 'should redirect to label page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');
is_deeply($edit->data, {
        name => 'controller label',
        sort_name => 'label, controller',
        type_id => 2,
        country_id => 1,
        label_code => 12345,
        comment => 'label created in controller_label.t',
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

# Test deleting artists via the website
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/delete');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',    
    }
);
ok($mech->success);
ok($mech->uri =~ qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'should redirect to label page via gid');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');
is_deeply($edit->data, { label_id => 2 });

# Test editing labels
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/edit');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'edit-label.name' => 'controller label',
        'edit-label.sort_name' => 'label, controller',
        'edit-label.type_id' => 2,
        'edit-label.label_code' => 12345,
        'edit-label.country_id' => 1,
        'edit-label.begin_date.year' => 1990,
        'edit-label.begin_date.month' => 01,
        'edit-label.begin_date.day' => 02,
        'edit-label.end_date.year' => 2003,
        'edit-label.end_date.month' => 4,
        'edit-label.end_date.day' => 15,
        'edit-label.comment' => 'label created in controller_label.t',
    }
);

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');
is_deeply($edit->data, {
        label => 2,
        new => {
            name => 'controller label',
            sort_name => 'label, controller',
            type_id => 2,
            country_id => 1,
            label_code => 12345,
            comment => 'label created in controller_label.t',
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
        },
        old => {
            name => 'Warp Records',
            sort_name => 'Warp Records',
            type_id => 1,
            country_id => 1,
            label_code => 2070,
            comment => 'Sheffield based electronica label',
            begin_date => {
                year => 1989,
                month => 2,
                day => 3
            },
            end_date => {
                year => 2008,
                month => 05,
                day => 19
            },
        }
    });

# Test merging labels
$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/merge');
xml_ok($mech->content);
my $response = $mech->submit_form(
    with_fields => {
        'filter.query' => 'Another',
    }
);
$response = $mech->submit_form(
    with_fields => {
        'results.selected_id' => 3
    });
$response = $mech->submit_form(
    with_fields => { 'confirm.edit_note' => ' ' }
);
ok($mech->uri =~ qr{/label/4b4ccf60-658e-11de-8a39-0800200c9a66});

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');
is_deeply($edit->data, {
        old_label => 2,
        new_label => 3,
    });

done_testing;
