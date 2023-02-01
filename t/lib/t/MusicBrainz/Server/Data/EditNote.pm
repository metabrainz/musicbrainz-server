package t::MusicBrainz::Server::Data::EditNote;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Exception;

BEGIN { use MusicBrainz::Server::Data::Gender };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::EditNote;
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test;

BEGIN {
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';

    sub edit_type { 111; }
    sub edit_name { 'mock edit' }
};

with 't::Context';

test all => sub {

my $raw_sql = <<'RAWSQL';
SET client_min_messages TO 'WARNING';
TRUNCATE edit CASCADE;
TRUNCATE edit_note CASCADE;

-- Test multiple edit_notes
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 111, 1, NOW());

-- Test a single note
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (2, 1, 111, 1, NOW());

-- Test no edit_notes
INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (3, 1, 111, 1, NOW());

INSERT INTO edit_data (edit, data) SELECT generate_series(1, 3), '{ "foo": "5" }';

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (1, 1, 1, 'This is a note');

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (2, 2, 1, 'This is a later note');

INSERT INTO edit_note (id, editor, edit, text)
    VALUES (3, 1, 2, 'Another edit note');

-- Dummy edits to allow editor 2 to vote
INSERT INTO edit (id, editor, type, status, expire_time)
    SELECT 3 + x, 2, 111, 2, now() FROM generate_series(1, 10) x;
INSERT INTO edit_data (edit, data)
    SELECT 3 + x, '{}' FROM generate_series(1, 10) x;

ALTER SEQUENCE edit_note_id_seq RESTART 4;

RAWSQL

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+edit_note');
MusicBrainz::Server::Test->prepare_raw_test_database($test->c, $raw_sql);

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type('MockEdit');

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);
my $en_data = MusicBrainz::Server::Data::EditNote->new(c => $test->c);
my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

my $editor2 = $editor_data->get_by_id(2);

# Multiple edit edit_notes
my $edit = $edit_data->get_by_id(1);
$en_data->load_for_edits($edit);
is(@{ $edit->edit_notes }, 2, 'Edit has two edit notes');
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
$en_data->load_for_edits($edit);
is(@{ $edit->edit_notes }, 1, 'Edit has one edit note');
check_note($edit->edit_notes->[0], 'MusicBrainz::Server::Entity::EditNote',
       editor_id => 1,
       edit_id => 2,
       text => 'Another edit note');

# No edit edit_notes
$edit = $edit_data->get_by_id(3);
$en_data->load_for_edits($edit);
is(@{ $edit->edit_notes }, 0, 'Edit has no edit notes');

# Insert a new edit note
$en_data->insert($edit->id, {
        editor_id => 3,
        text => 'This is a new edit note',
    });


$en_data->load_for_edits($edit);
is(@{ $edit->edit_notes }, 1, 'Edit has one edit note');
check_note($edit->edit_notes->[0], 'MusicBrainz::Server::Entity::EditNote',
        editor_id => 3,
        edit_id => 3,
        text => 'This is a new edit note');

# Make sure we can insert edit notes while already in a transaction
$test->c->sql->begin;
lives_ok {
    $en_data->insert($edit->id, {
            editor_id => 3,
            text => 'Note' })
} q(Edit notes don't die while in a transaction already);
$test->c->sql->commit;

# Test adding edit notes with email sending
$test->c->model('Vote')->enter_votes($editor2, { edit_id => $edit->id, vote => 1 });

$en_data->add_note($edit->id, { text => 'This is my note!', editor_id => 3 });

my $server = 'https://' . DBDefs->WEB_SERVER_USED_IN_EMAIL;
my $email_transport = MusicBrainz::Server::Email->get_test_transport;
is($email_transport->delivery_count, 2, 'Exactly two emails sent');

my $email2 = $email_transport->shift_deliveries->{email};
my $email = $email_transport->shift_deliveries->{email};

is($email->get_header('Subject'), 'Note added to your edit #' . $edit->id, 'Subject explains a note was added to edit');
is($email->get_header('To'), '"editor1" <editor1@example.com>', 'Email is addressed to editor1');
my $email_body = $email->object->body_str;
like($email_body, qr{$server/edit/${\ $edit->id }}, 'Email body contains edit url');
like($email_body, qr{'editor3' has added}, 'Email body mentions editor3');
like($email_body, qr{to your edit #${\ $edit->id }}, 'Email body mentions "your edit #"');
like($email_body, qr{This is my note!}, 'Email body has correct edit note text');

is($email2->get_header('Subject'), 'Note added to edit #' . $edit->id, 'Subject explains a note was added to edit');
is($email2->get_header('To'), '"editor2" <editor2@example.com>', 'Email is addressed to editor2');
my $email2_body = $email2->object->body_str;
like($email2_body, qr{$server/edit/${\ $edit->id }}, 'Email body contains edit url');
like($email2_body, qr{'editor3' has added}, 'Email body mentions editor3');
like($email2_body, qr{to edit #${\ $edit->id }}, 'Email body mentions "edit #"');
like($email2_body, qr{This is my note!}, 'Email body has correct edit note text');

};

sub check_note {
    my ($note, $class, %attrs) = @_;
    isa_ok($note, $class);
    is($note->$_, $attrs{$_}, "check_note: $_ is ".$attrs{$_})
        for keys %attrs;
    ok(defined $note->post_time, 'check_note: edit has post time');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
