package t::MusicBrainz::Server::Controller::Admin::WikiDoc::Create;
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks that the WikiDoc Add Page form is blocked for users without
the appropriate privileges, that it loads for privileged users, and that
it correctly submits edits.

=cut

test 'Create a new transcluded page' => sub {
    my ($test) = @_;
    my $c = $test->c;
    my $mech = $test->mech;

    $c->sql->do(<<~'SQL', md5_hex('new_editor:musicbrainz.org:password'));
        INSERT INTO editor (id,
                            name,
                            password,
                            privs,
                            ha1,
                            email,
                            email_confirm_date)
             VALUES (1,
                     'new_editor',
                     '{CLEARTEXT}password',
                     0,
                     ?,
                     $$foo@example.com$$,
                     now())
        SQL

    $c->model('WikiDocIndex')->set_page_version('Transclusion_Testing', undef);

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get('/admin/wikidoc/create');
    is(
        $mech->status,
        403,
        'Non-privileged user cannot access the Add Page WikiDoc page',
    );

    $c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 255
         WHERE id = 1
        SQL

    $mech->get_ok(
        '/admin/wikidoc/create',
        'Transclusion editors can access the Add Page WikiDoc page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'wikidoc.page' => 'Transclusion_Testing',
                'wikidoc.version' => 1
            },
        },
        'The form returned a 2xx response code')
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::WikiDoc::Change');
    is(
        $edit->data->{page},
        'Transclusion_Testing',
        'The page name was stored correctly',
    );
    is($edit->data->{old_version}, undef, 'There is no old page version');
    is(
        $edit->data->{new_version},
        1,
        'The new page version was stored correctly',
    );
};

1;
