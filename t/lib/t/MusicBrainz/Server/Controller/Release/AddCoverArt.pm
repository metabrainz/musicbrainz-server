package t::MusicBrainz::Server::Controller::Release::AddCoverArt;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context', 't::Mechanize';

test 'Test adding cover art' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    my $long_comment_string = 'This is a comment of more than 256 characters.' .
        (' (MBS-9069)' x 40);

    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 'e1dd8fee8ee728b0ddc8027d3a3db478');

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist', 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, join_phrase)
    VALUES (1, 0, 1, 'Artist', '');

INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 'Release', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '14b9d183-7dab-42ba-94a3-7388a66604b8', 'Release', 1, 1);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $test->cache_aware_c->store->set('cover_art_upload_nonce:12345', 'xyz');

    $mech->get_ok('/release/14b9d183-7dab-42ba-94a3-7388a66604b8/add-cover-art');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'add-cover-art.position' => 1,
                'add-cover-art.id' => 12345,
                'add-cover-art.comment' => $long_comment_string,
                'add-cover-art.nonce' => 'xyz',
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
        cover_art_comment => $long_comment_string,
        cover_art_mime_type => 'image/jpeg'
    });
};

1;
