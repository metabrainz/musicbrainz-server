package t::MusicBrainz::Server::Edit::Label::Create;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::Create; }

use MusicBrainz::Server::Constants qw(
    $EDIT_LABEL_CREATE
    $STATUS_APPLIED
    $STATUS_FAILEDVOTE
    $STATUS_OPEN
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( reject_edit );

test all => sub {
    my $test = shift;
    my $c = $test->c;

    my $edit = create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');

    ok(defined $edit->label_id);

    my ($edits, undef) = $c->model('Edit')->find({ label => $edit->label_id }, 10, 0);
    is($edits->[0]->id, $edit->id);

    $edit = $c->model('Edit')->get_by_id($edit->id);
    my $label = $c->model('Label')->get_by_id($edit->label_id);
    is($label->name, '!K7');
    is($label->type_id, 1);
    is($label->comment, 'Funky record label');
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
    is(scalar @$ipi_codes, 2, 'Label has two ipi codes');

    my @ipis = sort map { $_->ipi } @$ipi_codes;
    is($ipis[0], '00262168177', 'first ipi is 00262168177');
    is($ipis[1], '00284373936', 'second ipi is 00284373936');

    my $isni_codes = $c->model('Label')->isni->find_by_entity_id($label->id);
    is(scalar @$isni_codes, 2, 'Label has two isni codes');

    my @isnis = sort map { $_->isni } @$isni_codes;
    is($isnis[0], '0000000106750994', 'first isni is 0000000106750994');
    is($isnis[1], '0000000106750995', 'second isni is 0000000106750995');
};

test 'Uniqueness violations are caught before insertion (MBS-6065)' => sub {
    my ($test) = @_;

    my $c = $test->c;

    $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,
        name => 'I am a dupe without a comment',
        comment => '',
        ipi_codes => [],
        isni_codes => []
    );

    is(exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_LABEL_CREATE,
            editor_id => 1,
            name => 'I am a dupe without a comment',
            comment => '',
            ipi_codes => [],
            isni_codes => []
        );
    }, 'A disambiguation comment is required for this entity.');

    $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,
        name => 'I am a dupe with a comment',
        comment => 'a comment',
        ipi_codes => [],
        isni_codes => []
    );

    is(exception {
        $c->model('Edit')->create(
            edit_type => $EDIT_LABEL_CREATE,
            editor_id => 1,
            name => 'I am a dupe with a comment',
            comment => 'a comment',
            ipi_codes => [],
            isni_codes => []
        );
    }, 'The given values duplicate an existing row.');
};

test q(Rejected edits are applied if the label can't be deleted) => sub {
    my $test = shift;
    my $c = $test->c;

    my $edit = create_edit($c, privileges => $UNTRUSTED_FLAG);
    my $label_id = $edit->entity_id;

    $c->sql->do(<<~"SQL");
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '01aa077b-ea92-437a-833f-4bf617dac3e7', 'A', 'A');

        INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'AC', 1);
        INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
            VALUES (1, 1, 'AC', 0, '');

        INSERT INTO release_group (id, gid, name, artist_credit)
            VALUES (1, 'b654bda0-4304-47d5-83a6-fd9cafc85cf3', 'RG', 1);

        INSERT INTO release (id, gid, name, artist_credit, release_group)
            VALUES (1, '357cfecb-8afd-41b7-a357-c1fde7ce46cd', 'R', 1, 1);

        INSERT INTO release_label (release, label, catalog_number) VALUES (1, $label_id, '');
        SQL

    reject_edit($c, $edit);
    is($edit->status, $STATUS_APPLIED);
};

test 'Rejecting an "Add label" edit where the label has subscriptions (MBS-8690)' => sub {
    my ($test) = @_;

    my $c = $test->c;

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,
        name => 'Label',
        comment => '',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is($edit->status, $STATUS_OPEN);
    $c->model('Label')->subscription->subscribe(1, $edit->label_id);
    reject_edit($c, $edit);
    is($edit->status, $STATUS_FAILEDVOTE);
};

sub create_edit {
    my ($c, %opts) = @_;

    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_CREATE,
        editor_id => 1,
        name => '!K7',
        type_id => 1,
        comment => 'Funky record label',
        label_code => 7306,
        begin_date => { year => 1995, month => 1, day => 12 },
        end_date => { year => 2005, month => 5, day => 30 },
        ipi_codes => [ '00284373936', '00262168177' ],
        isni_codes => [ '0000000106750994', '0000000106750995' ],
        %opts,
    );
}

1;
