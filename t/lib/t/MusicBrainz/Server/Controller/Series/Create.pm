package t::MusicBrainz::Server::Controller::Series::Create;
use utf8;
use strict;
use warnings;

use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok capture_edits );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic series creation works, including adding
relationships during the creation process.

=cut

test 'Adding a new series, including relationships' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' }
    );

    $mech->get_ok(
        '/series/create',
        'Fetched the series creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->post_ok(
            '/series/create',
            {
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
            },
            'The form returned a 2xx response code'
        );
    } $c;

    ok(
        $mech->uri =~ qr{/series/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$},
        'The user is redirected to the series page after entering the edit',
    );

    $mech->content_contains(
        '//en.wikipedia.org/wiki/Totally_Nonexistent_Series',
        'Series page contains added Wikipedia link',
    );

    is(@edits, 4, 'Four edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Series::Create');

    cmp_deeply(
        $edits[0]->data,
        {
            name => 'totally nonexistent series',
            comment => 'a comment longer than the name :(',
            type_id => 4,
            ordering_type_id => 2,
        },
        'The first edit contains the right data',
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply(
        $edits[1]->data,
        {
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
        },
        'The second edit contains the right data',
    );

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

    cmp_deeply(
        $edits[2]->data,
        {
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
        },
        'The third edit contains the right data',
    );

    isa_ok($edits[3], 'MusicBrainz::Server::Edit::Relationship::Create');

    cmp_deeply(
        $edits[3]->data,
        {
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
        },
        'The fourth edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok(
        '/edit/' . $edits[0]->id,
        'Fetched the Add series edit page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'totally nonexistent series',
        'The edit page contains the series name',
    );
    $mech->text_contains(
        'Work series',
        'The edit page contains the series type',
    );
    $mech->text_contains(
        'a comment longer than the name :(',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains(
        'Manual',
        'The edit page contains the ordering type name',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
