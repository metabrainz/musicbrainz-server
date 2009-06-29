#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Label::Merge';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_MERGE );
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $sql = Sql->new($c->dbh);
my $sql_raw = Sql->new($c->raw_dbh);
$sql->Begin;
$sql_raw->Begin;

my $edit = $edit_data->create(
    edit_type => $EDIT_LABEL_MERGE,
    editor_id => 1,
    old_label_id => 1,
    new_label_id => 2,
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Merge');
is_deeply($edit->entities, { label => [ 1, 2 ]});
is_deeply($edit->entity_id, [ 1, 2 ]);
is($edit->entity_model, 'Label');

my $label = $label_data->get_by_id(1);
is($label->edits_pending, 1);

$label = $label_data->get_by_id(2);
is($label->edits_pending, 1);

$edit_data->accept($edit);

$label = $label_data->get_by_id(1);
ok(!defined $label);

$label = $label_data->get_by_id(2);
ok(defined $label);
is($label->edits_pending, 0);

$sql->Commit;
$sql_raw->Commit;
