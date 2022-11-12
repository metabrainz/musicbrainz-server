package t::MusicBrainz::Server::Controller::Label::EditAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether alias editing for labels works, including whether
the sort name defaults to the name when not explicitly entered (blanked).

=cut

test 'Editing alias' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/alias/1/edit',
        'Fetched the edit alias page',
    );
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edited alias',
                # HTML::Form doesn't understand selected=""
                # so we need to specifically set this
                'edit-alias.type_id' => '1',
            });
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::EditAlias');
    is_deeply(
        $edit->data,
        {
            entity => {
                id => 2,
                name => 'Warp Records'
            },
            alias_id  => 1,
            new => {
                name => 'Edited alias',
            },
            old => {
                name => 'Test Label Alias',
            }
        },
        'The edit contains the right data',
    );

    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->content_contains(
        'Warp Records',
        'Edit page contains artist name',
    );
    $mech->content_contains(
        'Test Label Alias',
        'Edit page contains old alias name',
    );
    $mech->content_contains(
        'Edited alias',
        'Edit page contains new alias name',
    );
};

test 'MBS-6896: Removing alias sort name defaults it to name' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/alias/1/edit',
        'Fetched the edit alias page',
    );

    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'edit-alias.name' => 'Edit #2',
                'edit-alias.sort_name' => '',
            });
    } $test->c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::EditAlias');
    is(
        $edit->data->{new}{sort_name},
        'Edit #2',
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
