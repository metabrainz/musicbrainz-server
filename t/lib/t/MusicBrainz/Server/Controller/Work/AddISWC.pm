package t::MusicBrainz::Server::Controller::Work::AddISWC;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test 'Test adding an ISWC to a work' => sub {
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

INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name) VALUES (1, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1);
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/work/54b9d183-7dab-42ba-94a3-7388a66604b8/add-iswc');
    my @edits = capture_edits {
        $mech->submit_form(
            with_fields => {
                'add-iswc.iswc' => 'T-101.724.790-2',
            }
        );
    } $c;

    is(@edits, 1);
    my ($edit) = @edits;

    isa_ok($edit, 'MusicBrainz::Server::Edit::Work::AddISWCs');
    is_deeply($edit->data, {
        iswcs => [{
            work => {
                id => 1,
                name => 'Work'
            },
            iswc => 'T-101.724.790-2'
        }]
    });
};

1;
