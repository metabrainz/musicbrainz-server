#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::Edit' }
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $sql = Sql->new($c->dbh);
my $sql_raw = Sql->new($c->raw_dbh);
$sql->Begin;
$sql_raw->Begin;

my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $label = $label_data->get_by_id(2);
my $edit = $edit_data->create(
    edit_type => $EDIT_LABEL_EDIT,
    editor_id => 2,

    label => $label,
    name => 'Warped Records',
    comment => 'Weird electronica record label',
    country_id => 1,
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Edit');
is($edit->entity_model, 'Label');
is($edit->entity_id, $label->id);
is_deeply($edit->entities, { label => [ $label->id ] });

$label = $label_data->get_by_id(2);
is($label->edits_pending, 1);

$edit_data->accept($edit);;
my $label2 = $label_data->get_by_id(2);
is($label2->name, 'Warped Records');
is($label2->comment, 'Weird electronica record label');
is($label2->country_id, 1);
is($label2->edits_pending, 0);

$sql->Commit;
$sql_raw->Commit;
