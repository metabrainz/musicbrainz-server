package t::MusicBrainz::Server::Edit::ReleaseGroup::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Edit }

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

my $rg = $c->model('ReleaseGroup')->get_by_id(1);
my $edit = create_edit($c, $rg);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');

my ($edits) = $c->model('Edit')->find({ release_group => 1 }, 10, 0);
is($edits->[0]->id, $edit->id);

$rg = $c->model('ReleaseGroup')->get_by_id(1);
is($rg->edits_pending, 1);
is_unchanged($rg);

reject_edit($c, $edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
is_unchanged($rg);
is($rg->edits_pending, 0);

$edit = create_edit($c, $rg);
accept_edit($c, $edit);
$rg = $c->model('ReleaseGroup')->get_by_id(1);
$c->model('ArtistCredit')->load($rg);
is($rg->edits_pending, 0);
is($rg->artist_credit->name, 'Break & Silent Witness');
is($rg->primary_type_id, 1);
is($rg->comment, 'EP');
is($rg->name, 'We Know');

};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit   => $c->model('ReleaseGroup')->get_by_id(1),
        name => 'Renamed release group',
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit   => $c->model('ReleaseGroup')->get_by_id(1),
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    name => 'New ac name'
                }
            ]
        }
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $rg = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('ArtistCredit')->load($rg);
    is ($rg->name, 'Renamed release group', 'release group renamed');
    is ($rg->artist_credit->name, 'New ac name', 'date changed');
};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit   => $c->model('ReleaseGroup')->get_by_id(1),
        name      => 'Renamed release group',
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    name => 'New ac name'
                }
            ]
        }
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit   => $c->model('ReleaseGroup')->get_by_id(1),
        comment   => 'Comment BAR',
        artist_credit => {
            names => [
                {
                    artist => {
                        id => 1,
                        name => 'Name',
                    },
                    name => 'New ac name 2'
                }
            ]
        }
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $rg = $c->model('ReleaseGroup')->get_by_id(1);
    $c->model('ArtistCredit')->load($rg);
    is ($rg->name, 'Renamed release group', 'release group renamed');
    is ($rg->comment, '');
    is ($rg->artist_credit->name, 'New ac name', 'date changed');
};

test 'Reject edits that try to set the release group type to something that doesnt exist' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit => $c->model('ReleaseGroup')->get_by_id(1),
        primary_type_id => 1001,
    );

    my $exception = exception { $edit->accept };
    ok(defined $exception, 'Did not accept edit');
    isa_ok($exception, 'MusicBrainz::Server::Edit::Exceptions::FailedDependency');
    is($exception->message,
       "This edit changes the release group's primary type to a type that no longer exists.");
};

test 'Changing the secondary types for a release group is not always an auto-edit' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_rg_delete');
    $c->sql->do(<<'EOSQL');
INSERT INTO release_group_secondary_type (id, name) VALUES (1, 'Remix');
EOSQL

    {
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASEGROUP_EDIT,
            editor_id => 1,
            to_edit => $c->model('ReleaseGroup')->get_by_id(1),
            secondary_type_ids => [ 1 ]
        );

        ok (!$edit->is_open, 'Adding a secondary type should be an auto-edit');
    }

    {
        my $rg = $c->model('ReleaseGroup')->get_by_id(1);
        $c->model('ReleaseGroupSecondaryType')->load_for_release_groups($rg);
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASEGROUP_EDIT,
            editor_id => 1,
            to_edit => $rg,
            secondary_type_ids => [ ]
        );

        ok ($edit->is_open, 'Further changes to secondary types should not be a auto-edits');
    }
};

sub create_edit {
    my ($c, $rg) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 1,
        to_edit => $rg,

        artist_credit => {
            names => [
                {
                    artist => { id => 1, name => 'Break' },
                    name => 'Break',
                    join_phrase => ' & ',
                },
                {
                    artist => { id => 1, name => 'Break' },
                    name => 'Silent Witness',
                    join_phrase => '',
                }
            ] },
        name => 'We Know',
        comment => 'EP',
        primary_type_id => 1,
    );
}

sub is_unchanged {
    my $rg = shift;
    is($rg->name, 'Release Name');
    is($rg->primary_type_id, undef);
    is($rg->comment, '');
    is($rg->artist_credit_id, 1);
}

1;
