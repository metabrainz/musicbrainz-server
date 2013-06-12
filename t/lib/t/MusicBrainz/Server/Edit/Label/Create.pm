package t::MusicBrainz::Server::Edit::Label::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Create; }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Constants qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+labeltype');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834');
INSERT INTO editor (id, name, password, ha1) VALUES (4, 'modbot', '{CLEARTEXT}pass', 'a359885742ca76a15d93724f1a205cc7');
EOSQL

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

my $ipi_codes = $c->model('Label')->ipi->find_by_entity_id($label->id);
is(scalar @$ipi_codes, 2, "Label has two ipi codes");

my @ipis = sort map { $_->ipi } @$ipi_codes;
is($ipis[0], '00262168177', "first ipi is 00262168177");
is($ipis[1], '00284373936', "first ipi is 00284373936");

my $isni_codes = $c->model('Label')->isni->find_by_entity_id($label->id);
is(scalar @$isni_codes, 2, "Label has two isni codes");

my @isnis = sort map { $_->isni } @$isni_codes;
is($isnis[0], '0000000106750994', "first isni is 0000000106750994");
is($isnis[1], '0000000106750995', "first isni is 0000000106750995");

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
        end_date => { year => 2005, month => 5, day => 30 },
        ipi_codes => [ '00284373936', '00262168177' ],
        isni_codes => [ '0000000106750994', '0000000106750995' ]
    );
}

1;
