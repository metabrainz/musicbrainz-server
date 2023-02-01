package t::MusicBrainz::Server::Controller::Label::DeleteAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks that label alias deletion works, and that it requires
an edit note.

=cut

test 'Deleting an alias' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/alias/1/delete',
        'Fetched the delete alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
                with_fields => {
                    'confirm.edit_note' =>
                        q(Some edit note since it's required)
                }
            },
            'The form returned a 2xx response code',
        );
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::DeleteAlias');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 2,
                name => 'Warp Records'
            },
            alias_id  => 1,
            name      => 'Test Label Alias',
            sort_name => 'Test Label Alias',
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
            ended => 0,
            type_id => 1,
            locale => undef,
            primary_for_locale => 0,
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Warp Records',
        'The edit page contains the label name',
    );
    $mech->content_contains(
        'Test Label Alias',
        'The edit page contains the alias name',
    );
};

test 'Edit note is required' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/alias/1/delete',
        'Fetched the delete alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form_ok({
                with_fields => {
                    'confirm.edit_note' => ''
                }
            },
            'The form returned a 2xx response code',
        );
    } $test->c;

    is(@edits, 0, 'No edit was entered');

    $mech->content_contains(
        'You must provide an edit note',
        'Contains warning about edit note being required',
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
