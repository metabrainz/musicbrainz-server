package t::MusicBrainz::Server::Controller::Admin::WikiDoc::Create;
use Digest::MD5 qw( md5_hex );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test 'Create a new transcluded page' => sub {
    my ($test) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do('INSERT INTO editor (id, name, password, privs, ha1, email, email_confirm_date) VALUES (?, ?, ?, ?, ?, $$foo@example.com$$, now())',
                1, 'new_editor', '{CLEARTEXT}password', 255, md5_hex('new_editor:musicbrainz.org:password'));

    $c->model('WikiDocIndex')->set_page_version('Transclusion_Testing', undef);

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/admin/wikidoc/create');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'wikidoc.page' => 'Transclusion_Testing',
                'wikidoc.version' => 1
            }
        })
    } $c;

    is(@edits, 1);

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::WikiDoc::Change');
    is($edit->data->{page}, 'Transclusion_Testing');
    is($edit->data->{old_version}, undef);
    is($edit->data->{new_version}, 1);
};

1;
