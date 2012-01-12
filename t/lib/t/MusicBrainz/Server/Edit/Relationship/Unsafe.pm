package t::MusicBrainz::Server::Edit::Relationship::Unsafe;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Rejecting an "add url" relationships should remove the unused URL' => sub {
    my $test = shift;
    my $c = MusicBrainz::Server::Test->create_test_context;

    $c->sql->auto_commit(1);
    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'foo', 'pass');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, '9f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1);
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, short_link_phrase)
    VALUES
        (1, '2476be45-3090-43b3-a948-a8f972b4065c', 'artist', 'url', 'mugshot', '-', '-', '-');
EOSQL

    my $url = $c->model('URL')->find_or_insert('http://example.com');
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'url',
        entity0 => $c->model('Artist')->get_by_id(1),
        entity1 => $url,
        link_type => $c->model('LinkType')->get_by_id(1),
        begin_date => { },
        end_date => { },
        attributes => [ ],
    );

    reject_edit($c, $edit);

    ok(!defined $c->model('URL')->get_by_id($url->id));

    _cleanup($c);
};

test 'Rejecting an "add url" relationships should not remove in use URLs' => sub {
    my $test = shift;
    my $c = MusicBrainz::Server::Test->create_test_context;

    $c->sql->auto_commit(1);
    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'foo', 'pass');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, '9f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1),
    (2, '1f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1);
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, short_link_phrase)
    VALUES
        (1, '2476be45-3090-43b3-a948-a8f972b4065c', 'artist', 'url', 'mugshot', '-', '-', '-');
INSERT INTO url (id, gid, url) VALUES (1, 'd1410d4f-0fe3-4452-919f-b883a2a5ff2b', 'http://example.com/');
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 2, 1);
ALTER SEQUENCE l_artist_url_id_seq RESTART 2;
EOSQL

    my $url = $c->model('URL')->find_or_insert('http://example.com/');
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'url',
        entity0 => $c->model('Artist')->get_by_id(1),
        entity1 => $url,
        link_type => $c->model('LinkType')->get_by_id(1),
        begin_date => { },
        end_date => { },
        attributes => [ ],
    );

    reject_edit($c, $edit);

    ok(defined $c->model('URL')->get_by_id($url->id));

    _cleanup($c);
};

test 'Accepting remove URL relationships should remove the unused URL' => sub {
    my $test = shift;
    my $c = MusicBrainz::Server::Test->create_test_context;

    $c->sql->auto_commit(1);
    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'foo', 'pass');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, '9f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1);
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, short_link_phrase)
    VALUES
        (1, '2476be45-3090-43b3-a948-a8f972b4065c', 'artist', 'url', 'mugshot', '-', '-', '-');
INSERT INTO url (id, gid, url) VALUES (1, 'd1410d4f-0fe3-4452-919f-b883a2a5ff2b', 'http://example.com/');
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 1, 1);
EOSQL

    my $url = $c->model('URL')->find_or_insert('http://example.com/');
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'url',
        relationship => $c->model('Relationship')->get_by_id(qw( artist url ), 1)
    );

    accept_edit($c, $edit);

    ok(!defined $c->model('URL')->get_by_id($url->id));

    _cleanup($c);
};

test 'Accepting remove URL relationships should not remove in use URLs' => sub {
    my $test = shift;
    my $c = MusicBrainz::Server::Test->create_test_context;

    $c->sql->auto_commit(1);
    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'foo', 'pass');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, '9f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1),
    (2, '1f810bfa-e051-44ed-b170-8fb9ca14fab2', 1, 1);
INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, short_link_phrase)
    VALUES
        (1, '2476be45-3090-43b3-a948-a8f972b4065c', 'artist', 'url', 'mugshot', '-', '-', '-');
INSERT INTO url (id, gid, url) VALUES (1, 'd1410d4f-0fe3-4452-919f-b883a2a5ff2b', 'http://example.com/');
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 1, 1), (2, 1, 2, 1);
EOSQL

    my $url = $c->model('URL')->find_or_insert('http://example.com/');
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'url',
        relationship => $c->model('Relationship')->get_by_id(qw( artist url ), 1)
    );

    accept_edit($c, $edit);

    ok(defined $c->model('URL')->get_by_id($url->id));

    _cleanup($c);
};

sub _cleanup {
    my $c = shift;
    $c->sql->auto_commit(1);
    $c->sql->do(<<'EOSQL');
SET client_min_messages TO 'warning';
TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE link_type CASCADE;
TRUNCATE url CASCADE;
EOSQL
}

1;
