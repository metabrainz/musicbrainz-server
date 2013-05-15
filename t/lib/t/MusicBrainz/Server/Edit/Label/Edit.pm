package t::MusicBrainz::Server::Edit::Label::Edit;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Edit }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

my $label = $c->model('Label')->get_by_id(2);
my $edit = create_full_edit($c, $label);

isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');

$edit = $c->model('Edit')->get_by_id($edit->id);
$label = $c->model('Label')->get_by_id(2);
is_unchanged($label);
is($label->edits_pending, 1);

my ($edits, $hits) = $c->model('Edit')->find({ label => $edit->label_id }, 10, 0);
is($edits->[0]->id, $edit->id);

reject_edit($c, $edit);
$label = $c->model('Label')->get_by_id($edit->label_id);
is_unchanged($label);
is($label->edits_pending, 0);

$edit = create_full_edit($c, $label);
accept_edit($c, $edit);

$label = $c->model('Label')->get_by_id($edit->label_id);
is($label->name, 'Edit Name');
is($label->sort_name, 'Edit Sort');
is($label->type_id, 1);
is($label->comment, "Edit comment");
is($label->label_code, 12345);
is($label->begin_date->year, 1995);
is($label->begin_date->month, 1);
is($label->begin_date->day, 12);
is($label->end_date->year, 2005);
is($label->end_date->month, 5);
is($label->end_date->day, 30);
is($label->edits_pending, 0);

my $ipi_codes = $c->model('Label')->ipi->find_by_entity_id($label->id);
is(scalar @$ipi_codes, 1, "Label has one ipi code after accepting edit");
isa_ok($ipi_codes->[0], "MusicBrainz::Server::Entity::LabelIPI");
is($ipi_codes->[0]->ipi, '00262168177');

my $isni_codes = $c->model('Label')->isni->find_by_entity_id($label->id);
is(scalar @$isni_codes, 1, "Label has one isni code after accepting edit");
isa_ok($isni_codes->[0], "MusicBrainz::Server::Entity::LabelISNI");
is($isni_codes->[0]->isni, '0000000106750994');

};

test 'Check conflicts (non-conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        name => 'Renamed label',
        ipi_codes => [ '00284373936' ],
        isni_codes => [ ],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        comment   => 'Comment change',
        ipi_codes => [ '00284373936' ],
        isni_codes => [ ],
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok !exception { $edit_2->accept }, 'accepted edit 2';

    my $label = $c->model('Label')->get_by_id(2);
    is ($label->name, 'Renamed label', 'label renamed');
    is ($label->comment, 'Comment change', 'comment changed');

    # check IPI code non-conflict
    my $edit_3 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        ipi_codes => [ '00333333333' ],
        isni_codes => [ ],
    );

    # edit 4 only adds an ipi code.  that edit 3 changes an existing ipi code
    # shouldn't have any affect on being able to apply edit 4.
    my $edit_4 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        ipi_codes => [ '00284373936', '00444444444' ],
        isni_codes => [ ],
    );

    ok !exception { $edit_3->accept }, 'accepted edit 3 (change ipi code)';
    ok !exception { $edit_4->accept }, 'accepted edit 4 (add ipi code)';

    my @ipi_codes = sort map { $_->ipi } @{ $c->model('Label')->ipi->find_by_entity_id(2) };
    is($ipi_codes[0], '00333333333', 'edit 3 correctly replaced ipi code');
    is($ipi_codes[1], '00444444444', 'edit 4 correctly added ipi code');

};

test 'Check conflicts (conflicting edits)' => sub {
    my $test = shift;
    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_delete');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        name      => 'Renamed label',
        sort_name => 'Sort FOO',
        ipi_codes => [ '00284373936' ],
        isni_codes => [ ],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        comment   => 'Comment change',
        sort_name => 'Sort BAR',
        ipi_codes => [ '00284373936' ],
        isni_codes => [ ],
    );

    ok !exception { $edit_1->accept }, 'accepted edit 1';
    ok  exception { $edit_2->accept }, 'could not accept edit 2';

    my $label = $c->model('Label')->get_by_id(2);
    is ($label->name, 'Renamed label', 'label name from edit 1');
    is ($label->sort_name, 'Sort FOO', 'sort name from edit 1');
    is ($label->comment, '', 'no comment');
};

test 'Editing two labels into a conflict fails gracefully' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_label_merge');

    my $edit_1 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(2),
        name => 'Conflicting name',
        comment => 'Conflicting comment',
        ipi_codes => [],
        isni_codes => [ ],
    );

    my $edit_2 = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,
        to_edit   => $c->model('Label')->get_by_id(3),
        name => 'Conflicting name',
        comment => 'Conflicting comment',
        ipi_codes => [],
        isni_codes => [ ],
    );

    ok !exception { $edit_1->accept }, 'First edit can be applied';

    my $exception = exception { $edit_2->accept };
    isa_ok $exception, 'MusicBrainz::Server::Edit::Exceptions::GeneralError';
    like $exception->message, qr{//localhost/label/da34a170-7f7f-11de-8a39-0800200c9a66},
        'Error message contains the URL of the conflict';
};

sub create_full_edit {
    my ($c, $label) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_EDIT,
        editor_id => 1,

        to_edit => $label,
        name => 'Edit Name',
        sort_name => 'Edit Sort',
        comment => 'Edit comment',
        area_id => 221,
        type_id => 1,
        label_code => 12345,
        begin_date => { year => 1995, month => 1, day => 12 },
        end_date => { year => 2005, month => 5, day => 30 },
        ipi_codes => [ '00262168177' ],
        isni_codes => [ '0000000106750994' ]
    );
}

sub is_unchanged {
    my $label = shift;
    is($label->name, 'Label Name');
    is($label->sort_name, 'Label Name');
    is($label->$_, undef) for qw( area_id label_code );
    is($label->comment, '');
    ok($label->begin_date->is_empty);
    ok($label->end_date->is_empty);
}

1;
