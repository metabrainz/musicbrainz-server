package t::MusicBrainz::Server::Controller::Release::AddCoverArt;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Test adding cover art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'caa_editor', password => 'password' } );

    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/add-cover-art');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'add-cover-art.position' => 1,
                'add-cover-art.id' => 12345,
                'add-cover-art.comment' => ''
            }
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::AddCoverArt');
    is_deeply($edit->data, {
        entity => {
            mbid => '14b9d183-7dab-42ba-94a3-7388a66604b8',
            id => 1,
            name => 'Release'
        },
        cover_art_types => [],
        cover_art_position => 1,
        cover_art_id => 12345,
        cover_art_comment => ''
    });
};

1;
