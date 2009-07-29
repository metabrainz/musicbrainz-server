#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Label::Create';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $edit = $edit_data->create(
    edit_type => $EDIT_LABEL_CREATE,
    name => '!K7',
    sort_name => '!K7 Recordings',
    type_id => 1,
    comment => 'Funky record label',
    label_code => 7306,
    editor_id => 1
);

isa_ok($edit, 'MusicBrainz::Server::Edit::Label::Create');
is($edit->entity_model, 'Label');
is($edit->entity_id, $edit->label_id);
is_deeply($edit->entities, { label => [ $edit->label_id ] });

ok(defined $edit->label_id);
ok(defined $edit->id);

my $label = $label_data->get_by_id($edit->label_id);
ok(defined $label);
is($label->name, '!K7');
is($label->sort_name, '!K7 Recordings');
is($label->type_id, 1);
is($label->comment, "Funky record label");
is($label->label_code, 7306);
is($label->edits_pending, 0);
