package t::MusicBrainz::Server::Controller::Release::ReorderCoverArt;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Test reordering cover art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_test_database($c, '+caa');

    $c->sql->do(<<'EOSQL');

INSERT INTO edit (id, editor, type, data, status, expire_time) VALUES (222, 10, 316, '', 2, now());
INSERT INTO cover_art_archive.cover_art (id, release, mime_type, edit, ordering)
  VALUES (12346, 1, 'image/jpeg', 1, 1), (12347, 1, 'image/jpeg', 1, 2);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'caa_editor', password => 'password' } );

    my $new_comment = 'Adding a comment';
    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/reorder-cover-art');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'reorder-cover-art.artwork.0.id' => 12346,
                'reorder-cover-art.artwork.0.position' => 2,
                'reorder-cover-art.artwork.1.id' => 12347,
                'reorder-cover-art.artwork.1.position' => 1,
            }
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::ReorderCoverArt');
    my $data = $edit->data;

    is_deeply(
        $data->{new},
        [ { id => 12346, position => 2 } ,
          { id => 12347, position => 1 } ],
        'Correctly reorders artwork');
};

1;
