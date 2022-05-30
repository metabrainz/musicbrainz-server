package t::MusicBrainz::Server::Edit::Relationship::Create;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Create }

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_CREATE
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

my $edit = _create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Create');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 3 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

($edits, $hits) = $c->model('Edit')->find({ artist => 4 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
is($rel->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
ok(!defined $rel);

# Test accepting the edit
$edit = _create_edit($c);
accept_edit($c, $edit);
$rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
ok(defined $rel);
$c->model('Link')->load($rel);
$c->model('LinkType')->load($rel->link);
is($rel->link->type->id, 104);
is($rel->link->begin_date->year, 1994);
is($rel->link->end_date->year, 1995);

subtest 'Text attributes of value 0 are supported' => sub {
    my $e0 = $c->model('Artist')->get_by_id(3);
    my $e1 = $c->model('Event')->get_by_id(1);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        entity0 => $e0,
        entity1 => $e1,
        link_type => $c->model('LinkType')->get_by_id(798),
        attributes => [
            {
                type => { gid => 'ebd303c3-7f57-452a-aa3b-d780ebad868d' },
                text_value => 0
            }
        ],
    );

    my $rel = $c->model('Relationship')->get_by_id('artist', 'event', $edit->entity_id);
    $c->model('Link')->load($rel);

    is($rel->link->attributes->[0]->text_value, 0);
};

subtest 'Instrument credits can be added with a new relationship' => sub {
    my $e0 = $c->model('Artist')->get_by_id(3);
    my $e1 = $c->model('Artist')->get_by_id(4);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        entity0 => $e0,
        entity1 => $e1,
        link_type => $c->model('LinkType')->get_by_id(103),
        attributes => [
            {
                type => {
                    gid => '63021302-86cd-4aee-80df-2270d54f4978'
                },
                credited_as => 'crazy guitar'
            }
        ],
    );

    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', $edit->entity_id);
    $c->model('Link')->load($rel);

    is($rel->link->attributes->[0]->credited_as, 'crazy guitar');
};

};

test 'Entities load correctly after being merged (MBS-2477)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $edit = _create_edit($c);
    $c->model('Artist')->merge(5, [4]);
    $c->model('Edit')->load_all($edit);

    is($edit->display_data->{relationship}{entity1_id}, 5);
};

test 'Adding an Amazon relationship updates the release ASIN' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_edit');

    my $e0 = $c->model('Release')->get_by_id(1);
    my $e1 = $c->model('URL')->get_by_id(263685);

    $c->model('Release')->load_meta($e0);

    is(
        $e0->amazon_asin,
        undef,
        'Release ASIN is unset to start',
    );

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'release',
        type1 => 'url',
        entity0 => $e0,
        entity1 => $e1,
        link_type => $c->model('LinkType')->get_by_id(77),
        begin_date => undef,
        end_date => undef,
        attributes => [],
        ended => 0,
        privileges => $UNTRUSTED_FLAG,
    );

    accept_edit($c, $edit);

    $e0 = $c->model('Release')->get_by_id(1);
    $c->model('Release')->load_meta($e0);

    is(
        $e0->amazon_asin,
        'B00005CDNG',
        'Release ASIN is set after adding relationship',
    );
};

sub _create_edit {
    my ($c, %args) = @_;

    my $e0 = $c->model('Artist')->get_by_id(3);
    my $e1 = $c->model('Artist')->get_by_id(4);
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_CREATE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        entity0 => $e0,
        entity1 => $e1,
        link_type => $c->model('LinkType')->get_by_id(104),
        begin_date => { year => 1994 },
        end_date => { year => 1995 },
        attributes => [ ],
        ended => 1,
        privileges => $UNTRUSTED_FLAG,
        %args,
    );
}

1;
