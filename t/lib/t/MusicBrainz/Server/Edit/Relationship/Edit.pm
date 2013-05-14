package t::MusicBrainz::Server::Edit::Relationship::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 0, "no edit pending on the relationship");
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 1, "link type id = 1");
is($rel->link->begin_date->year, undef, "no begin date");
is($rel->link->end_date->year, undef, "no end date");

my $edit = _create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Edit');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($hits, 1, "Found 1 edit for artist 1");
is($edits->[0]->id, $edit->id, "... which has the same id as the edit just created");

($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
is($hits, 1, "Found 1 edit for artist 2");
is($edits->[0]->id, $edit->id, "... which has the same id as the edit just created");

$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
is($rel->edits_pending, 1, "The relationship has 1 edit pending.");

# Test rejecting the edit
reject_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel);
is($rel->edits_pending, 0, "After rejecting the edit, no edit pending on the relationship");

# Test accepting the edit
$edit = _create_edit($c);
accept_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
ok(defined $rel, "After accepting the edit, the relationship has...");
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 2, "... type id 2");
is($rel->link->begin_date->year, 1994, "... begin year 1994");
is($rel->link->end_date->year, 1995, "... end year 1995");
is($rel->entity0_id, 1, '... entity 0 is artist 1');
is($rel->entity1_id, 3, '... entity 1 is artist 3');

$c->sql->do('SET CONSTRAINTS ALL IMMEDIATE');
$c->sql->do('SET CONSTRAINTS ALL DEFERRED');
$c->sql->do('TRUNCATE artist CASCADE');
$c->sql->do('TRUNCATE link_type CASCADE');
$c->model('Edit')->load_all($edit);

ok(defined $edit->display_data->{old});
is($edit->display_data->{old}->entity0->name, 'Artist 1');
is($edit->display_data->{old}->entity1->name, 'Artist 2');
is($edit->display_data->{old}->phrase, 'member');
is($edit->display_data->{new}->entity0->name, 'Artist 1');
is($edit->display_data->{new}->entity1->name, 'Artist 3');
is($edit->display_data->{new}->phrase, 'support');

};

test 'Editing a relationship more than once fails subsequent edits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit_1 = _create_edit($c);
    my $edit_2 = _create_edit($c);

    accept_edit($c, $edit_1);

    isa_ok exception { $edit_2->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship fails if the relationship has been deleted' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit_1 = _create_edit($c);

    $c->model('Relationship')->delete('artist', 'artist', 1);

    isa_ok exception { $edit_1->accept },
        'MusicBrainz::Server::Edit::Exceptions::FailedDependency';
};

test 'Editing a relationship refreshes existing cover art' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, '9d0ed9ec-ebd4-40d3-80ec-af70c07c3667', 1, 1);
INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 1);
INSERT INTO release_group (id, name, artist_credit, gid)
  VALUES (1, 1, 1, '8265e53b-94d8-4700-bcd2-c3d25dcf104d');
INSERT INTO release (id, gid, artist_credit, name, release_group)
  VALUES (1, 'aa289662-5b07-425c-a3e7-bbb6898ff46d', 1, 1, 1),
         (2, '362e3ac2-5afb-4d14-95be-3b808da95121', 1, 1, 1);
UPDATE release_coverart
SET cover_art_url = 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg';
INSERT INTO url (id, gid, url)
  VALUES (1, '24332737-b876-4d5e-9c30-e414b4570bda', 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase,
    reverse_link_phrase, long_link_phrase)
  VALUES (1, '46687254-01e8-41a9-833f-183f1f25e487', 'release', 'url',
    'cover art link', 'cover art link', 'cover art link', 'cover art link');
INSERT INTO link (id, link_type) VALUES (1, 1);
INSERT INTO l_release_url (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
EOSQL

    my $rel = $c->model('Relationship')->get_by_id('release', 'url', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        type0 => 'release',
        type1 => 'url',
        relationship => $rel,
        entity0 => $c->model('Release')->get_by_id(2)
    );

    accept_edit($c, $edit);

    my $r1 = $c->model('Release')->get_by_id(1);
    $c->model('Release')->load_meta($r1);
    is($r1->cover_art_url, undef);

    my $r2 = $c->model('Release')->get_by_id(2);
    $c->model('Release')->load_meta($r2);
    is($r2->cover_art_url, 'http://www.archive.org/download/CoverArtsForVariousAlbum/karenkong-mulakan.jpg');
};

sub _create_edit {
    my $c = shift;

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(2),
        begin_date => { year => 1994 },
        end_date => { year => 1995 },
        entity1 => $c->model('Artist')->get_by_id(3)
    );
}

sub _create_edit_change_direction {
    my $c = shift;

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        change_direction => 1,
        relationship => $rel,
        link_type => $c->model('LinkType')->get_by_id(1),
        begin_date => undef,
        end_date => undef,
        attributes => [],
    );
}

1;
