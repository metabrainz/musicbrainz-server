#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 26;
use Test::Exception;
BEGIN { use_ok 'MusicBrainz::Server::Data::Gender' };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::EditNote;
use MusicBrainz::Server::Test;

BEGIN {
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';

    sub edit_type { 111; }

    MockEdit->register_type;
};

my $raw_sql = <<'RAWSQL';
SET client_min_messages TO 'WARNING';
TRUNCATE edit CASCADE;
TRUNCATE edit_note CASCADE;

-- Test multiple edit_notes
INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (1, 1, 111, 1, '<data><foo>5</foo></data>', NOW());

-- Test a single note
INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (2, 1, 111, 1, '<data><foo>5</foo></data>', NOW());

-- Test no edit_notes
INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (3, 1, 111, 1, '<data><foo>5</foo></data>', NOW());

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (1, 1, 1, 'This is a note');

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (2, 2, 1, 'This is a later note');

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (3, 1, 2, 'Another edit note');

ALTER SEQUENCE edit_note_id_seq RESTART 4;

RAWSQL

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_raw_test_database($c, $raw_sql);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $en_data = MusicBrainz::Server::Data::EditNote->new(c => $c);

# Multiple edit edit_notes
my $edit = $edit_data->get_by_id(1);
$en_data->load($edit);
is(@{ $edit->edit_notes }, 2);
check_note($edit->edit_notes->[0], 'MusicBrainz::Server::Entity::EditNote',
       editor_id => 1,
       edit_id => 1,
       text => 'This is a note');

check_note($edit->edit_notes->[1], 'MusicBrainz::Server::Entity::EditNote',
       editor_id => 2,
       edit_id => 1,
       text => 'This is a later note');

# Single edit note
$edit = $edit_data->get_by_id(2);
$en_data->load($edit);
is(@{ $edit->edit_notes }, 1);
check_note($edit->edit_notes->[0], 'MusicBrainz::Server::Entity::EditNote',
       editor_id => 1,
       edit_id => 2,
       text => 'Another edit note');

# No edit edit_notes
$edit = $edit_data->get_by_id(3);
$en_data->load($edit);
is(@{ $edit->edit_notes }, 0);

# Insert a new edit note
$en_data->insert($edit->id, {
        editor_id => 3,
        text => 'This is a new edit note',
    });

$en_data->load($edit);
is(@{ $edit->edit_notes }, 1);
check_note($edit->edit_notes->[0], 'MusicBrainz::Server::Entity::EditNote',
        editor_id => 3,
        edit_id => 3,
        text => 'This is a new edit note');

# Make sure we can insert edit notes while already in a transaction
my $sql = Sql->new($c->raw_dbh);
$sql->Begin;
lives_ok {
    $en_data->insert($edit->id, {
            editor_id => 3,
            text => 'Note' })
};
$sql->Commit;

sub check_note {
    my ($note, $class, %attrs) = @_;
    isa_ok($note, $class);
    is($note->$_, $attrs{$_})
        for keys %attrs;
    ok(defined $note->post_time);
}
