package t::MusicBrainz::Server::Edit::Work::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::Create }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use MusicBrainz::Server::Types qw( :edit_status );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+work');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Create');

ok(defined $edit->work_id);

my ($edits, $hits) = $c->model('Edit')->find({ work => $edit->work_id }, 10, 0);
is($edits->[0]->id, $edit->id);

my $work = $c->model('Work')->get_by_id($edit->work_id);
ok(defined $work);
is($work->name, 'Mrs. Bongo');
is($work->comment => 'Work comment');
is($work->type_id, 1);
is($work->iswc, 'T-000.000.001-0');

is($work->edits_pending, 0);
is($edit->status, $STATUS_APPLIED, 'add work edits should be autoedits');

};

sub create_edit
{
    my $c = shift;
    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_WORK_CREATE,
        name => 'Mrs. Bongo',
        comment => 'Work comment',
        type_id => 1,
        iswc => 'T-000.000.001-0'
    );
}

1;
