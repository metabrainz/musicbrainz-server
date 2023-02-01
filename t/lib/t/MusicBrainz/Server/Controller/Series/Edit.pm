package t::MusicBrainz::Server::Controller::Series::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply ignore );
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Edit', 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic series editing works, and whether editing
the parts of series data works.

=cut

test 'Editing a series' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    prepare_test($test);

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit',
        'Fetched the series editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-series.name' => 'New Name!',
                'edit-series.comment' => 'new comment!',
                'edit-series.ordering_type_id' => 2,
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d$},
        'The user is redirected to the series page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Series::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d',
                name => 'Test Recording Series',
            },
            new => {
                name => 'New Name!',
                comment => 'new comment!',
                ordering_type_id => 2,

            },
            old => {
                name => 'Test Recording Series',
                comment => 'test comment 1',
                ordering_type_id => 1,
            },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Test Recording Series',
        'The edit page contains the old series name',
    );
    $mech->text_contains(
        'New Name!',
        'The edit page contains the new series name',
    );
    $mech->text_contains(
        'Automatic',
        'The edit page contains the old series ordering type',
    );
    $mech->text_contains(
        'Manual',
        'The edit page contains the new series ordering type',
    );
    $mech->text_contains(
        'test comment 1',
        'The edit page contains the old disambiguation',
    );
    $mech->text_contains(
        'new comment!',
        'The edit page contains the new disambiguation',
    );
};

test 'Editing parts of series data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    prepare_test($test);

    # Make the ordering type manual so we can test changing that too
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        UPDATE series SET ordering_type = 2 WHERE id = 1
        SQL

    my @edits = capture_edits {
        $mech->post_ok(
            '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edit',
            {
                'edit-series.name' => 'Test Recording Series',
                'edit-series.comment' => 'test comment 1',
                'edit-series.type_id' => 3,
                'edit-series.ordering_type_id' => 2,
                'edit-series.rel.0.relationship_id' => 1,
                'edit-series.rel.0.link_type_id' => 740,
                'edit-series.rel.0.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                'edit-series.rel.0.attributes.0.text_value' => 'B1',
                'edit-series.rel.1.relationship_id' => 2,
                'edit-series.rel.1.link_type_id' => 740,
                'edit-series.rel.1.attributes.0.type.gid' => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a',
                'edit-series.rel.1.attributes.0.text_value' => 'B11',
                'edit-series.rel.1.link_order' => '3',
            },
            'The form returned a 2xx response code'
        );
    } $c;

    is(@edits, 3, 'Three edits were entered');

    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Relationship::Edit');

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

    cmp_deeply(
        $edits[0]->data,
        {
            link => ignore(),
            relationship_id => ignore(),
            type0 => 'recording',
            type1 => 'series',
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
            new => {
                attributes => [{ %$number_attribute, text_value => 'B1' }],
            },
            old => {
                attributes => [{ %$number_attribute, text_value => 'A1' }],
            },
        },
        'The first relationship edit has the right data'
    );

    isa_ok($edits[1], 'MusicBrainz::Server::Edit::Relationship::Edit');

    cmp_deeply(
        $edits[1]->data,
        {
            link => ignore(),
            relationship_id => ignore(),
            type0 => 'recording',
            type1 => 'series',
            entity0_credit => '',
            entity1_credit => '',
            edit_version => 2,
            new => {
                attributes => [{ %$number_attribute, text_value => 'B11' }],
            },
            old => {
                attributes => [{ %$number_attribute, text_value => 'A11' }],
            },
        },
        'The second relationship edit has the right data'
    );

    isa_ok($edits[2], 'MusicBrainz::Server::Edit::Relationship::Reorder');

    cmp_deeply(
        $edits[2]->data,
        {
            edit_version => 2,
            link_type => ignore(),
            relationship_order => [{
                relationship => ignore(),
                old_order => 2,
                new_order => 3,
            }],
        },
        'The reorder relationship edit has the right data',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+series');

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'editor', password => 'pass' }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
