package t::MusicBrainz::Server::Controller::Artist::Edits;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( accept_edit html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether artist edits are correctly listed under both the
"all edits" and the "open edits" lists.

=cut

test 'Test that edits appear on the edit lists' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist',
    );

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edit');
    html_ok($mech->content);
    $mech->submit_form(
        with_fields => {
            'edit-artist.name' => 'history viewing',
            'edit-artist.rename_artist_credit' => undef
        }
    );

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Edit');

    is ($edit->auto_edit, 0, 'The edit is not an auto edit');

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/edits',
        'Fetched artist all edits list',
    );
    $mech->content_contains(
        '/edit/' . $edit->id,
        'The all edits list contains the open edit id',
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/open_edits',
        'Fetched artist open edits list',
    );
    $mech->content_contains(
        '/edit/' . $edit->id,
        'The open edits list contains the open edit id',
    );

    accept_edit($c, $edit);

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/edits',
        'Fetched artist all edits list again',
    );
    $mech->content_contains(
        '/edit/' . $edit->id,
        'The all edits list still contains the closed edit id',
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/open_edits',
        'Fetched artist open edits list again',
    );
    $mech->content_lacks(
        '/edit/' . $edit->id,
        'The open edits list no longer contains the closed edit id',
    );
};

1;
