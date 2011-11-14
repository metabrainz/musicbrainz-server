package t::MusicBrainz::Server::Edit::Relationship::Delete;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Delete }

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use MusicBrainz::Server::Types qw( $AUTO_EDITOR_FLAG );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

subtest 'Test edit creation/rejection' => sub {
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 0);

    my $edit = _create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    ($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 1);

    # Test rejecting the edit
    reject_edit($c, $edit);

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel);
    is($rel->edits_pending, 0);
};

subtest 'Creating as an auto-editor still requires voting' => sub {
    my $edit = _create_edit($c, privileges => $AUTO_EDITOR_FLAG);
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel, 'relationship should still exist');
    is($rel->edits_pending, 1, 'relationship should have an edit pending');
};

subtest 'Test edit acception' => sub {
    # Test accepting the edit
    my $edit = _create_edit($c);
    accept_edit($c, $edit);
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(!defined $rel);
};

};

test 'Accepting remove URL relationships should remove the unused URL' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
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
};

test 'Accepting remove URL relationships should not remove in use URLs' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
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
};

sub _create_edit {
    my $c = shift;
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => $rel,
        @_
    );
}

1;
