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
        artist     => 9876,
        type       => 14,
        rowid      => 1234,
        prevvalue  => 'Removed Alias',
        newvalue   => undef,
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::RemoveArtistAlias');

my $upgraded = $edit->upgrade;
isa_ok($upgraded, 'MusicBrainz::Server::Edit::Artist::DeleteAlias');
is_deeply($upgraded->data, {
    name      => 'Removed Alias',
    alias_id  => 1234,
    entity_id => 9876
});

done_testing;
