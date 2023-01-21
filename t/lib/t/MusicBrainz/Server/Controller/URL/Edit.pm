package t::MusicBrainz::Server::Controller::URL::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( capture_edits html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic URL editing works, and whether clearing the
credited-as fields works as expected.

=cut

test 'Editing a URL' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url');
    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    $mech->get_ok(
        '/url/9201840b-d810-4e0f-bb75-c791205f5b24/edit',
        'Fetched the URL editing page',
    );
    html_ok($mech->content);

    my @edits = capture_edits {
        $mech->submit_form_ok({
            with_fields => {
                'edit-url.url' => 'http://link.example',
            },
        },
        'The form returned a 2xx response code')
    } $c;

    ok(
        $mech->uri =~ qr{/url/9201840b-d810-4e0f-bb75-c791205f5b24$},
        'The user is redirected to the URL page after entering the edit',
    );

    is(@edits, 1, 'The edit was entered');

    my $edit = shift(@edits);

    isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Edit');

    is_deeply(
        $edit->data,
        {
            entity => {
                id => 1,
                gid => '9201840b-d810-4e0f-bb75-c791205f5b24',
                name => 'http://musicbrainz.org/'
            },
            new => {
                url => 'http://link.example/',
            },
            old => {
                url => 'http://musicbrainz.org/',
            },
            affects => 0, # not realistic, but true for the test data (unused URL entity)
            is_merge => 0,
        },
        'The edit contains the right data',
    );

    # Test display of edit data
    $mech->get_ok('/edit/' . $edit->id, 'Fetched the edit page');
    html_ok($mech->content);
    $mech->text_contains(
        'http://musicbrainz.org/',
        'The edit page contains the old URI',
    );
    $mech->text_contains(
        'http://link.example',
        'The edit page contains the new URI',
    );
};

test 'Clearing relationship credits from URL rels (MBS-8590)' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $c->sql->do(<<~'SQL');
        INSERT INTO url (id, gid, url)
            VALUES (1, '94d14d6f-d937-4f24-a814-423cdb977c74', 'http://www.bobmarley.com/');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, '7aed3034-2bc3-4495-a0fb-f6d2a55c7b20', 'Bob Marley', 'Marley, Bob');
        INSERT INTO link (id, link_type) VALUES (1, 183);
        INSERT INTO l_artist_url (id, link, entity0, entity1, entity0_credit)
            VALUES (1, 1, 3, 1, 'Bob Marley');
        SQL

    $mech->get('/login');
    $mech->submit_form(
        with_fields => { username => 'new_editor', password => 'password' }
    );

    # Submitting without an edit-url.rel.0.entity0_credit field is a noop
    $mech->post_ok(
        '/url/94d14d6f-d937-4f24-a814-423cdb977c74/edit',
        {
            'edit-url.url' => 'http://www.bobmarley.com/',
            'edit-url.rel.0.relationship_id' => '1',
            'edit-url.rel.0.target' => '7aed3034-2bc3-4495-a0fb-f6d2a55c7b20',
            'edit-url.rel.0.backward' => '1',
            'edit-url.rel.0.link_type_id' => '183',
            'edit-url.edit_note' => '',
        },
        'The form returned a 2xx response code when skipping entity0_credit field',
    );

    my $credit = $c->sql->select_single_value(
        'SELECT entity0_credit FROM l_artist_url WHERE id = 1',
    );
    is(
        $credit,
        'Bob Marley',
        'The credit did not change when the credit field was simply omitted',
    );

    # Submitting with an empty edit-url.rel.0.entity0_credit field clears the credit (MBS-8590)
    $mech->post_ok(
        '/url/94d14d6f-d937-4f24-a814-423cdb977c74/edit',
        {
            'edit-url.url' => 'http://www.bobmarley.com/',
            'edit-url.rel.0.relationship_id' => '1',
            'edit-url.rel.0.target' => '7aed3034-2bc3-4495-a0fb-f6d2a55c7b20',
            'edit-url.rel.0.backward' => '1',
            'edit-url.rel.0.link_type_id' => '183',
            'edit-url.rel.0.entity0_credit' => '',
            'edit-url.edit_note' => '',
        },
        'The form returned a 2xx response code when posting empty entity0_credit field',
    );

    $credit = $c->sql->select_single_value(
        'SELECT entity0_credit FROM l_artist_url WHERE id = 1',
    );
    is(
        $credit,
        '',
        'The credit was removed when the credit field was explicitly blanked',
    );
};

1;
