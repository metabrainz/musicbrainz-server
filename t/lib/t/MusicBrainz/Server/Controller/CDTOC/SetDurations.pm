package t::MusicBrainz::Server::Controller::CDTOC::SetDurations;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, privs, email, website, bio, email_confirm_date, member_since, last_login_date, edits_accepted, edits_rejected, auto_edits_accepted, edits_failed, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 0, 'test@editor.org', 'http://musicbrainz.org', 'biography', '2005-10-20', '1989-07-23', now(), 12, 2, 59, 9, 'e1dd8fee8ee728b0ddc8027d3a3db478');
EOSQL

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-/set-durations?medium=1');
html_ok($mech->content);

$mech->submit_form(
    with_fields => {
        'confirm.edit_note' => ' ',
    }
);

my $cdtoc = $c->model('CDTOC')->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');
is($edit->data->{medium_id}, 1);
is($edit->data->{cdtoc}{id}, $cdtoc->id);

like($mech->uri, qr{/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-$});
$mech->content_contains('Thank you, your edit has been');

};

1;
