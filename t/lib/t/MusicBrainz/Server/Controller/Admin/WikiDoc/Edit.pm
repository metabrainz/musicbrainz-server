package t::MusicBrainz::Server::Controller::Admin::WikiDoc::Edit;
use Digest::MD5 qw( md5_hex );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

test 'Edit an already transcluded page' => sub {
    my ($test) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do('INSERT INTO editor (id, name, password, privs, ha1) VALUES (?, ?, ?, ?, ?)',
                1, 'new_editor', '{CLEARTEXT}password', 255, md5_hex('new_editor:musicbrainz.org:password'));

    $c->model('WikiDocIndex')->set_page_version('Transclusion_Testing', 1);

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/admin/wikidoc/edit?page=Transclusion_Testing');
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'wikidoc.version' => 10
            }
        })
    } $c;

    is(@edits, 1);

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::WikiDoc::Change');
    is($edit->data->{page}, 'Transclusion_Testing');
    is($edit->data->{old_version}, 1);
    is($edit->data->{new_version}, 10);
};

1;
