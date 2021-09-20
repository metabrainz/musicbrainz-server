package t::MusicBrainz::Server::Controller::URL::Edit;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply re );
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+url');
    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    # Test editing urls
    $mech->get_ok('/url/9201840b-d810-4e0f-bb75-c791205f5b24/edit');
    my $response = $mech->submit_form(
        with_fields => {
            'edit-url.url' => 'http://google.com',
        });

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::URL::Edit');
    cmp_deeply($edit->data, {
        entity => {
            id => 1,
            gid => re('[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
            name => 'http://musicbrainz.org/'
        },
        new => {
            url => 'http://google.com/',
        },
        old => {
            url => 'http://musicbrainz.org/',
        },
        affects => 0, # not realistic, but true for the test data (unused URL entity)
        is_merge => 0,
    });

    $mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
    html_ok($mech->content, '..valid xml');
    $mech->content_contains('http://google.com', '..has new URI');
    $mech->content_contains('http://musicbrainz.org/', '..has old URI');
};

test 'MBS-8590: Clearing relationship credits' => sub {
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

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    # Submitting without an edit-url.rel.0.entity0_credit field is a noop
    $mech->post('/url/94d14d6f-d937-4f24-a814-423cdb977c74/edit', {
        'edit-url.url' => 'http://www.bobmarley.com/',
        'edit-url.rel.0.relationship_id' => '1',
        'edit-url.rel.0.target' => '7aed3034-2bc3-4495-a0fb-f6d2a55c7b20',
        'edit-url.rel.0.backward' => '1',
        'edit-url.rel.0.link_type_id' => '183',
        'edit-url.edit_note' => '',
    });

    my $credit = $c->sql->select_single_value('SELECT entity0_credit FROM l_artist_url WHERE id = 1');
    is($credit, 'Bob Marley');

    # Submitting with an empty edit-url.rel.0.entity0_credit field clears the credit (MBS-8590)
    $mech->post('/url/94d14d6f-d937-4f24-a814-423cdb977c74/edit', {
        'edit-url.url' => 'http://www.bobmarley.com/',
        'edit-url.rel.0.relationship_id' => '1',
        'edit-url.rel.0.target' => '7aed3034-2bc3-4495-a0fb-f6d2a55c7b20',
        'edit-url.rel.0.backward' => '1',
        'edit-url.rel.0.link_type_id' => '183',
        'edit-url.rel.0.entity0_credit' => '',
        'edit-url.edit_note' => '',
    });

    $credit = $c->sql->select_single_value('SELECT entity0_credit FROM l_artist_url WHERE id = 1');
    is($credit, '');
};

1;
