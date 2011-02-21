package t::MusicBrainz::Server::Edit::ReleaseGroup::Edit;
use Test::Routine;
use Test::More;

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
is($rg->type_id, 1);
is($rg->comment, 'EP');
is($rg->name, 'We Know');

};

sub create_edit {
    my ($c, $rg) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASEGROUP_EDIT,
        editor_id => 2,
        to_edit => $rg,

        artist_credit => [
            { name => 'Break', artist => 1 },
            ' & ',
            { name => 'Silent Witness', artist => 1 },
        ],
        name => 'We Know',
        comment => 'EP',
        type_id => 1,
    );
}

sub is_unchanged {
    my $rg = shift;
    is($rg->name, 'Release Name');
    is($rg->type_id, undef);
    is($rg->comment, undef);
    is($rg->artist_credit_id, 1);
}

1;
