package t::MusicBrainz::Server::Controller::Release::ReorderCoverArt;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Test reordering cover art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<'EOSQL');
INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 1, 'new_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 1, '');

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '14b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 1);

INSERT INTO edit (id, editor, type, data, status, expire_time) VALUES (1, 1, 316, '', 2, now());
INSERT INTO cover_art_archive.cover_art (id, release, edit, ordering)
  VALUES (12345, 1, 1, 1), (12346, 1, 1, 2);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $new_comment = 'Adding a comment';
    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/reorder-cover-art');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'reorder-cover-art.artwork.0.id' => 12345,
                'reorder-cover-art.artwork.0.position' => 2,
                'reorder-cover-art.artwork.1.id' => 12346,
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
        [ { id => 12345, position => 2 } ,
          { id => 12346, position => 1 } ],
        'Correctly reorders artwork');
};

1;
