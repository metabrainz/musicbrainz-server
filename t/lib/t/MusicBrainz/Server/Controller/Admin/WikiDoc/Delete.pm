package t::MusicBrainz::Server::Controller::Admin::WikiDoc::Delete;
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks that the WikiDoc Remove Page form is blocked for users
without the appropriate privileges, that it loads for privileged users, and
that it correctly submits edits.

=cut

test 'Remove an already transcluded page' => sub {
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

    $c->model('WikiDocIndex')->set_page_version('Transclusion_Testing', 1);

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get('/admin/wikidoc/delete?page=Transclusion_Testing');
    is(
        $mech->status,
        403,
        'Non-privileged user cannot access the Remove Page WikiDoc page',
    );

    $c->sql->do(<<~'SQL');
        UPDATE editor
           SET privs = 255
         WHERE id = 1
        SQL

    $mech->get_ok(
        '/admin/wikidoc/delete?page=Transclusion_Testing',
        'Transclusion editors can access the Remove Page WikiDoc page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->form_name('confirm');
        $mech->click_button(name => 'confirm.submit');
    } $c;

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);
    isa_ok($edit, 'MusicBrainz::Server::Edit::WikiDoc::Change');
    is(
        $edit->data->{page},
        'Transclusion_Testing',
        'The page name was stored correctly',
    );
    is(
        $edit->data->{old_version},
        1,
        'The old page version was stored correctly',
    );
    is($edit->data->{new_version}, undef, 'There is no new page version');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
