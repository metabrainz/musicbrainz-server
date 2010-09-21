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
        type       => 11,
        rowid      => 456,
        prevvalue  => join "\n", (
            'To delete',
            '1919',
            '1',
            '5',
            '12345',
        ),
        newvalue   => '',
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

$mocks->expect($mock_sql, 'select_single_column_array')
    ->return([ 123 ]);

$mocks->expect($mock_sql, 'select_single_value')
    ->return(999);

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::RemoveTrack');

my $upgraded = $edit->upgrade;
is($upgraded, $edit);
is_deeply($upgraded->data, {
    release_ids  => [ 123 ],
    name         => 'To delete',
    recording_id => 999
});

done_testing;
