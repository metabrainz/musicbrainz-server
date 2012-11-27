package t::MusicBrainz::Server::Controller::Recording::AddISRC;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test 'Test adding an ISRC to a recording' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

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

INSERT INTO track_name (id, name) VALUES (1, 'Recording');
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/add-isrc');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'add-isrc.isrc' => 'GBAAA9000038',
            }
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is_deeply($edit->data, {
        isrcs => [{
            recording => {
                id => 1,
                name => 'Recording'
            },
            isrc => 'GBAAA9000038',
            source => 0
        }],
        client_version => undef
    });
};

1;
