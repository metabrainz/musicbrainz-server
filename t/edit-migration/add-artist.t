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
    artist     => 9876,
    moderator  => 101,
    tab        => 'artist',
    col        => 'name',
    type       => 17,
    status     => 2,
    rowid      => 9876,
    prevvalue  => undef,
    newvalue   => (join "\n", (
        'ArtistId=9876',
        'ArtistName=New artist',
        'SortName=New sort',
        'BeginDate=2001-01-02',
        'EndDate=2003-04-28',
        'Resolution=A created artist',
        'Type=2'
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
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::AddArtist');

my $upgraded = $edit->upgrade;
isa_ok($upgraded, 'MusicBrainz::Server::Edit::Artist::Create');
is_deeply($upgraded->data, {
    name       => 'New artist',
    sort_name  => 'New sort',
    begin_date => { year => '2001', month => '01', day => '02' },
    end_date   => { year => '2003', month => '04', day => '28' },
    comment    => 'A created artist',
    type_id    => 2,
});
is($upgraded->entity_id, 9876);

done_testing;
