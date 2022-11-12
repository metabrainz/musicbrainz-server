package t::MusicBrainz::Server::Controller::Series::Create;
use utf8;
use strict;
use warnings;

use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok capture_edits );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'editor', password => 'pass' } );

    $mech->get_ok('/series/create');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            '/series/create', {
                'edit-series.name' => 'totally nonexistent series',
                'edit-series.comment' => 'a comment longer than the name :(',
                'edit-series.type_id' => 4,
                'edit-series.ordering_type_id' => 2,
                'edit-series.url.0.link_type_id' => 744,
                'edit-series.url.0.text' => 'http://en.wikipedia.org/wiki/Totally_Nonexistent_Series',
                'edit-series.rel.0.link_type_id' => 743,
                'edit-series.rel.0.target' => '7e0e3ea0-d674-11e3-9c1a-0800200c9a66',
                'edit-series.rel.0.link_order' => 1,
                'edit-series.rel.0.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                'edit-series.rel.0.attributes.0.text_value' => '  Foo  ',
                'edit-series.rel.1.link_type_id' => 743,
                'edit-series.rel.1.target' => 'f89a8de8-f0e3-453c-9516-5bc3edd2fd88',
                'edit-series.rel.1.link_order' => 2,
                'edit-series.rel.1.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                'edit-series.rel.1.attributes.0.text_value' => 'Bar',
            }
        );
    } $c;

    ok($mech->success);
    ok($mech->uri =~ qr{/series/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})},
       'should redirect to series page via gid');
    $mech->content_contains('//en.wikipedia.org/wiki/Totally_Nonexistent_Series', '..has wikipedia link');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Series::Create');

    cmp_deeply($edits[0]->data, {
        name => 'totally nonexistent series',
        comment => 'a comment longer than the name :(',
        type_id => 4,
        ordering_type_id => 2,
    });

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply($edits[1]->data, {
        type0 => 'series',
        type1 => 'url',
        entity0 => {
            name => 'totally nonexistent series',
            id => 4,
            gid => ignore()
        },
        entity1 => {
            name => 'http://en.wikipedia.org/wiki/Totally_Nonexistent_Series',
            id => 1,
            gid => ignore()
        },
        link_type => {
            long_link_phrase => 'has a Wikipedia page at',
            link_phrase => 'Wikipedia',
            name => 'wikipedia',
            id => 744,
            reverse_link_phrase => 'Wikipedia page for'
        },
        ended => 0,
        edit_version => 2,
    });

    my $number_attribute = {
        type => {
            id => 788,
            gid => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
            name => 'number',
            root => {
                id => 788,
                gid => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                name => 'number',
            }
        }
    };

    isa_ok($edits[2], 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply($edits[2]->data, {
        type0 => 'series',
        type1 => 'work',
        entity0 => {
            name => 'totally nonexistent series',
            id => 4,
            gid => ignore()
        },
        entity1 => {
            name => 'Wōrk1',
            id => 1,
            gid => '7e0e3ea0-d674-11e3-9c1a-0800200c9a66'
        },
        link_type => {
            long_link_phrase => 'has part',
            link_phrase => 'has parts',
            name => 'part of',
            id => 743,
            reverse_link_phrase => 'part of'
        },
        ended => 0,
        link_order => 1,
        attributes => [{ %$number_attribute, text_value => 'Foo' }],
        edit_version => 2,
    });

    isa_ok($edits[3], 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply($edits[3]->data, {
        type0 => 'series',
        type1 => 'work',
        entity0 => {
            name => 'totally nonexistent series',
            id => 4,
            gid => ignore()
        },
        entity1 => {
            name => 'Wōrk2',
            id => 2,
            gid => 'f89a8de8-f0e3-453c-9516-5bc3edd2fd88'
        },
        link_type => {
            long_link_phrase => 'has part',
            link_phrase => 'has parts',
            name => 'part of',
            id => 743,
            reverse_link_phrase => 'part of'
        },
        ended => 0,
        link_order => 2,
        attributes => [{ %$number_attribute, text_value => 'Bar' }],
        edit_version => 2,
    });

    $mech->get_ok('/edit/' . $edits[0]->id, 'Fetch the edit page');
    $mech->content_contains('totally nonexistent series', '..has name');
    $mech->content_contains('a comment longer than the name :(', '..has comment');
    $mech->content_contains('Work', '..has type name');
    $mech->content_contains('Manual', '..has ordering type name');
};

1;
