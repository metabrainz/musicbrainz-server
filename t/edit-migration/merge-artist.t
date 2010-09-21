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
$mocks->expect($mock_sql, 'next_row_hash_ref')->return({
    id         => 12345,
    artist     => 2345,
    moderator  => 101,
    tab        => 'artist',
    col        => 'name',
    type       => 6,
    status     => 1,
    rowid      => 2345,
    prevvalue  => 'RATM',
    newvalue   => (join "\n", (
        'ArtistId=9876',
        'ArtistName=Rage Against the Machine',
    )),
    yesvotes   => 5,
    novotes    => 3,
    automod    => 1,
    opentime   => '2010-01-22 19:34:17+00',
    closetime  => '2010-01-29 19:34:17+00',
    expiretime => '2010-02-05 19:34:17+00'
});
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::MergeArtist');

my $upgraded = $edit->upgrade;
isa_ok($upgraded, 'MusicBrainz::Server::Edit::Artist::Merge');
is_deeply($upgraded->data, {
    new_entity_id => 9876,
    old_entities => [
        { id => 2345, name => 'RATM' }
    ]
});

done_testing;
