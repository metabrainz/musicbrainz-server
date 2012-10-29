package t::MusicBrainz::Server::Controller::Edit::Relationship::Create;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok capture_edits );

with 't::Context', 't::Mechanize';

test 'Can create a relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 1, 'new_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $recording = '99caac80-72e4-11de-8a39-0800200c9a66';
    my $artist    = 'e2a083a9-9942-4d6e-b4d2-8397320b95f7';

    $mech->get_ok("/edit/relationship/create?entity0=$recording&type0=recording&type1=artist&entity1=$artist");
    html_ok($mech->content);

    $mech->submit_form(
        with_fields => {
            'ar.link_type_id' => ''
        }
    );

    like($mech->uri, qr{/edit/relationship/create}, 'hasnt changed page for invalid form submission');
    $mech->content_contains('Link type is required');

    my ($edit) = capture_edits {
        $mech->submit_form(
            with_fields => {
                'ar.link_type_id' => '2',
                'ar.period.begin_date.year' => 1999
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edit->data->{entity0}{id}, '1');
    is($edit->data->{entity1}{id}, '1');
    is($edit->data->{type0}, 'artist');
    is($edit->data->{type1}, 'recording');
    is($edit->data->{link_type}{id}, 2);
    is_deeply($edit->data->{begin_date}, {
        year => 1999,
        month => undef,
        day => undef
    });
};

test 'Cannot create a relationship under a grouping relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO
    editor ( id, name, password, privs, email, website, bio,
             email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected,
             auto_edits_accepted, edits_failed)
    VALUES ( 1, 'new_editor', 'password', 0, 'test@editor.org', 'http://musicbrainz.org',
             'biography', '2005-10-20', '1989-07-23', '2009-01-01', 12, 2, 59, 9 );
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $recording = '99caac80-72e4-11de-8a39-0800200c9a66';
    my $artist    = 'e2a083a9-9942-4d6e-b4d2-8397320b95f7';

    $mech->get_ok("/edit/relationship/create?entity0=$recording&type0=recording&type1=artist&entity1=$artist");

    $mech->submit_form(
        with_fields => {
            'ar.link_type_id' => 3
        }
    );

    like($mech->uri, qr{/edit/relationship/create}, 'hasnt changed page for invalid form submission');
    $mech->content_contains('This relationship type is used to group other relationships.');
};

1;
