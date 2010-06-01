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
        type       => 67,
        rowid      => 123,
        prevvalue  => '',
        newvalue   => (join "\n", (
            'ReleaseGroupId0=123',
            'ReleaseGroupId1=456',
            'ReleaseGroupId2=789',
            'ReleaseGroupName0=RG1',
            'ReleaseGroupName1=RG2',
            'ReleaseGroupName2=RG3',
        )),
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::MergeReleaseGroups');

my $upgraded = $edit->upgrade;
isa_ok($upgraded, 'MusicBrainz::Server::Edit::ReleaseGroup::Merge');
is_deeply($upgraded->data, {
    new_entity => {
        id   => 123,
        name => 'RG1',
    },
    old_entities => [
        { id => 456, name => 'RG2' },
        { id => 789, name => 'RG3' },
    ]
});

done_testing;
