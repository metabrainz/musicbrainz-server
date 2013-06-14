package t::MusicBrainz::Server::Controller::Edit::Relationship::CreateURL;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok capture_edits );

with 't::Context', 't::Mechanize';

test 'Can create a URL relationship' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c, '+relationships');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO link_type (id, child_order, gid, entity_type0, entity_type1, name, link_phrase, long_link_phrase,
                       reverse_link_phrase, description)
    VALUES (42, 0, 'f8673e29-02a5-47b7-af61-dd4519328dd0', 'recording', 'url', 'review', 'review', 'review', 'review', 'desc');
INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 12, 2, 59, 9, 'e1dd8fee8ee728b0ddc8027d3a3db478');
EOSQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    my $recording = '99caac80-72e4-11de-8a39-0800200c9a66';
    $mech->get_ok("/edit/relationship/create_url?entity=$recording&type=recording");
    html_ok($mech->content);

    my ($edit) = capture_edits {
        $mech->submit_form(
            with_fields => {
                'ar.link_type_id' => '42',
                'ar.url' => 'http://gizoogle.com'
            }
        );
    } $c;

    ok(defined $edit);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');
    is($edit->data->{entity0}{id}, '1');
    is($edit->data->{entity1}{name}, 'http://gizoogle.com/');
    is($edit->data->{type0}, 'recording');
    is($edit->data->{type1}, 'url');
    is($edit->data->{link_type}{id}, 42);

    $mech->get_ok("/edit/relationship/create_url?entity=$recording&type=recording");
    ($edit) = capture_edits {
        $mech->submit_form(
            with_fields => {
                'ar.link_type_id' => '42',
                'ar.url' => 'http://gizoogle.com'
            }
        );

        $mech->content_contains('already exists');
    } $c;

    ok(!defined $edit);
};

1;
