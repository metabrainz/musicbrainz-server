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
        type       => 7,
        rowid      => 345,
        prevvalue  => 'Old Name',
        newvalue   => join "\n", (
            'Track name',
            '5',
            '345',
            'Joe Artist',
        )
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

$mocks->expect($mock_sql, 'select_single_column_array')
    ->return([ 123 ]);

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::AddTrack');

my $upgraded = $edit->upgrade;
is($upgraded, $edit);
is_deeply($upgraded->data, {
    release_ids => [ 123 ],
    name        => 'Track name',
    position    => 5,
    artist_name => 'Joe Artist',
});

done_testing;
