package t::MusicBrainz::Server::Controller::Label::AddAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether alias adding for labels works, including whether
the sort name defaults to the name when not explicitly entered.

=cut

test 'Adding alias with sort name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'An alias',
                'edit-alias.sort_name' => 'An alias sort name',
            },
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 2,
                name => 'Warp Records'
            },
            name => 'An alias',
            sort_name => 'An alias sort name',
            locale => undef,
            primary_for_locale => 0,
            begin_date => {
                year => undef,
                month => undef,
                day => undef
            },
            end_date => {
                year => undef,
                month => undef,
                day => undef
            },
            type_id => undef,
            ended => 0,
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);

    $mech->content_contains('Warp Records', 'Edit page contains label name');
    $mech->content_contains(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
        'Edit page contains artist link',
    );
    $mech->content_contains('An alias', 'Edit page contains alias name');
    $mech->content_contains(
        'An alias sort name',
        'Edit page contains the selected alias sort name',
    );
};

test 'MBS-6896: Adding alias without sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/add-alias',
        'Fetched the add alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-alias.name' => 'Another alias',
            }
        },
        'The form returned a 2xx response code')
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');
    is(
        $edit->data->{sort_name},
        'Another alias',
        'The (not specified) sort name in the edit data defaults to the name',
    );
};

sub prepare_test {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c);

    $test->mech->get('/login');
    $test->mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
