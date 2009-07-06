#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;

BEGIN {
    use_ok 'MusicBrainz::Server::Data::Edit';
    use_ok 'MusicBrainz::Server::Edit::Label::Delete';
}

use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $edit = $edit_data->create(
    edit_type => $EDIT_LABEL_DELETE,
    label_id => 1,
    editor_id => 1
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Delete');
is($edit->entity_model, 'Label');
is($edit->entity_id, 1);
is_deeply($edit->entities, { label => [ 1 ] });

my $label = $label_data->get_by_id(1);
ok(defined $label);
is($label->edits_pending, 1);

$edit_data->accept($edit);
$label = $label_data->get_by_id(1);
ok(!defined $label);
