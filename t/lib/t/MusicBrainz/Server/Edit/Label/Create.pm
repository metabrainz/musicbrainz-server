package t::MusicBrainz::Server::Edit::Label::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Create; }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+labeltype');

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');

ok(defined $edit->label_id);

my ($edits, $hits) = $c->model('Edit')->find({ label => $edit->label_id }, 10, 0);
is($edits->[0]->id, $edit->id);

$edit = $c->model('Edit')->get_by_id($edit->id);
my $label = $c->model('Label')->get_by_id($edit->label_id);
is($label->name, '!K7');
is($label->sort_name, '!K7 Recordings');
is($label->type_id, 1);
is($label->comment, "Funky record label");
is($label->label_code, 7306);
is($label->begin_date->year, 1995);
is($label->begin_date->month, 1);
is($label->begin_date->day, 12);
is($label->end_date->year, 2005);
is($label->end_date->month, 5);
is($label->end_date->day, 30);

is($edit->status, $STATUS_APPLIED, 'add label edits should be autoedits');
is($label->edits_pending, 0, 'add label edits should be autoedits');

};

sub create_edit
{
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,

        name => '!K7',
        sort_name => '!K7 Recordings',
        type_id => 1,
        comment => 'Funky record label',
        label_code => 7306,
        begin_date => { year => 1995, month => 1, day => 12 },
        end_date => { year => 2005, month => 5, day => 30 }
    );
}

1;
