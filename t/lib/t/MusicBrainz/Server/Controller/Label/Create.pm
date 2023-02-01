package t::MusicBrainz::Server::Controller::Label::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic label creation works.

=cut

test 'Adding a new label' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/label/create',
        'Fetched the label creation page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-label.name' => 'controller label',
                'edit-label.type_id' => 4,
                'edit-label.label_code' => 12345,
                'edit-label.area_id' => 221,
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
    } $test->c;

    ok(
        $mech->uri =~ qr{/label/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})},
        'The user is redirected to the label page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');

    is_deeply(
        $edit->data,
        {
            name => 'controller label',
            type_id => 4,
            area_id => 221,
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
            ended => 1,
            ipi_codes => [],
            isni_codes => [],
        },
        'The edit contains the right data',
    );


    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'controller label',
        'The edit page contains the label name',
    );
    $mech->text_contains(
        'Original Production',
        'The edit page contains the label type',
    );
    $mech->text_contains(
        'United Kingdom',
        'The edit page contains the area',
    );
    $mech->text_contains(
        'label created in controller_label.t',
        'The edit page contains the disambiguation',
    );
    $mech->text_contains(
        '1990-01-02',
        'The edit page contains the label begin date',
    );
    $mech->text_contains(
        '2003-04-15',
        'The edit page contains the label end date',
    );
    $mech->text_contains(
        '12345',
        'The edit page contains the label code',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
