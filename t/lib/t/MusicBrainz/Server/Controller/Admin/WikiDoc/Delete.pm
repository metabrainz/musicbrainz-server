package t::MusicBrainz::Server::Controller::Admin::WikiDoc::Delete;
use Digest::MD5 qw( md5_hex );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

use HTTP::Request::Common qw( POST );

with 't::Mechanize', 't::Context';

test 'Edit an already transcluded page' => sub {
    my ($test) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do('INSERT INTO editor (id, name, password, privs, ha1, email, email_confirm_date) VALUES (?, ?, ?, ?, ?, $$foo@example.com$$, now())',
                1, 'new_editor', '{CLEARTEXT}password', 255, md5_hex('new_editor:musicbrainz.org:password'));

    $c->model('WikiDocIndex')->set_page_version('Transclusion_Testing', 1);

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/admin/wikidoc/delete?page=Transclusion_Testing');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->request(POST $mech->uri, [ 'confirm.submit' => 1 ]);
    } $c;

    is(@edits, 1);

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::WikiDoc::Change');
    is($edit->data->{page}, 'Transclusion_Testing');
    is($edit->data->{old_version}, 1);
    is($edit->data->{new_version}, undef);
};

1;

