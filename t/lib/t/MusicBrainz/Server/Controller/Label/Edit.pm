package t::MusicBrainz::Server::Controller::Label::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic label editing works.

=cut

test 'Editing a label' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/edit',
        'Fetched the label editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-label.name' => 'controller label',
                'edit-label.type_id' => 2,
                'edit-label.label_code' => 12345,
                'edit-label.area_id' => 222,
                'edit-label.period.begin_date.year' => 1990,
                'edit-label.period.begin_date.month' => 1,
                'edit-label.period.begin_date.day' => 2,
                'edit-label.period.end_date.year' => 2003,
                'edit-label.period.end_date.month' => 4,
                'edit-label.period.end_date.day' => 15,
                'edit-label.comment' => 'label created in controller_label.t',
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190$},
        'The user is redirected to the label page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 2,
                gid => '46f0f4cd-8aab-4b33-b698-f459faf64190',
                name => 'Warp Records',
            },
            new => {
                name => 'controller label',
                type_id => 2,
                area_id => 222,
                label_code => 12345,
                comment => 'label created in controller_label.t',
                begin_date => {
                    year => 1990,
                    month => 1,
                    day => 2,
                },
                end_date => {
                    year => 2003,
                    month => 4,
                    day => 15,
                },
            },
            old => {
                name => 'Warp Records',
                type_id => 4,
                area_id => 221,
                label_code => 2070,
                comment => 'Sheffield based electronica label',
                begin_date => {
                    year => 1989,
                    month => 2,
                    day => 3,
                },
                end_date => {
                    year => 2008,
                    month => 5,
                    day => 19,
                },
            },
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'Warp Records',
        'The edit page contains the old label name',
    );
    $mech->text_contains(
        'controller label',
        'The edit page contains the new label name',
    );
    $mech->text_contains(
        'Original Production',
        'The edit page contains the new label type',
    );
    $mech->text_contains(
        'United Kingdom',
        'The edit page contains the old area',
    );
    $mech->text_contains(
        'United States',
        'The edit page contains the new area',
    );
    $mech->text_contains(
        '12345',
        'The edit page contains the old label code',
    );
    $mech->text_contains(
        '2070',
        'The edit page contains the new label code',
    );
    $mech->text_contains(
        '1989-02-03',
        'The edit page contains the old begin date',
    );
    $mech->text_contains(
        '1990-01-02',
        'The edit page contains the new begin date',
    );
    $mech->text_contains(
        '2008-05-19',
        'The edit page contains the old end date',
    );
    $mech->text_contains(
        '2003-04-15',
        'The edit page contains the new end date',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
