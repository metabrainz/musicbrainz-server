use strict;
use warnings;
use Test::More tests => 32;

BEGIN { use_ok 'MusicBrainz::Server::Data::Edit' };

{
    package MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 123 }
    MockEdit->register_type;
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Types qw( :edit_status );

my $raw_sql = <<'RAWSQL';
SET client_min_messages TO 'warning';
TRUNCATE edit CASCADE;
TRUNCATE edit_artist CASCADE;

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (1, 1, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (2, 1, 123, 2, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (3, 2, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (4, 2, 123, 2, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (5, 3, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 2);

RAWSQL

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_raw_test_database($c, $raw_sql);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

# Find all edits
my ($edits, $hits) = $edit_data->find({}, 0, 10);
is($hits, 5);
is(scalar @$edits, 5);

# Check we get the edits in descending ID order
is($edits->[$_]->id, 5 - $_) for (0..4);

# Find edits with a certain status
($edits, $hits) = $edit_data->find({ status => $STATUS_OPEN }, 0, 10);
is($hits, 3);
is(scalar @$edits, 3);
is($edits->[0]->id, 5);
is($edits->[1]->id, 3);
is($edits->[2]->id, 1);

# Find edits by a specific editor
($edits, $hits) = $edit_data->find({ editor => 1 }, 0, 10);
is($hits, 2);
is(scalar @$edits, 2);
is($edits->[0]->id, 2);
is($edits->[1]->id, 1);

# Find edits by a specific editor with a certain status
($edits, $hits) = $edit_data->find({ editor => 2, status => $STATUS_OPEN }, 0, 10);
is($hits, 1);
is(scalar @$edits, 1);
is($edits->[0]->id, 3);

# Find edits with 0 results
($edits, $hits) = $edit_data->find({ editor => 122 }, 0, 10);
is($hits, 0);
is(scalar @$edits, 0);

# Find edits by a certain artist
($edits, $hits) = $edit_data->find({ artist => 1 }, 0, 10);
is($hits, 2);
is(scalar @$edits, 2);
is($edits->[0]->id, 4);
is($edits->[1]->id, 1);

($edits, $hits) = $edit_data->find({ artist => 1, status => $STATUS_APPLIED }, 0, 10);
is($hits, 1);
is(scalar @$edits, 1);
is($edits->[0]->id, 4);

# Find edits over multiple entities
($edits, $hits) = $edit_data->find({ artist => [1,2] }, 0, 10);
is($hits, 1);
is(scalar @$edits, 1);
is($edits->[0]->id, 4);
