use strict;
use warnings;
use Test::More;
use Test::Mock::Context;

use aliased 'MusicBrainz::Server::Data::EditMigration';
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context;

my $mocks = Test::Mock::Context->new;
my $mock_sql = $mocks->mock('Sql');
$mocks->expect($mock_sql, 'select');
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(
    MusicBrainz::Server::Test->old_edit_row(
        type       => 4,
        rowid      => 456,
        prevvalue  => 'Old Name',
        newvalue   => 'New Name',
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

$mocks->expect($mock_sql, 'select_single_value')
    ->return(999);

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::EditTrackName');

my $upgraded = $edit->upgrade;
is($upgraded, $edit);
is_deeply($upgraded->data, {
    track_id     => 456,
    recording_id => 999,
    old          => { name => 'Old Name' },
    new          => { name => 'New Name' }
});

done_testing;
