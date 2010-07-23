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
        type       => 55,
        rowid      => 191060,
        prevvalue  => (join "\n", (
            'LabelName=Original name',
            'SortName=Original sort',
            'BeginDate=',
            'EndDate=',
            'Resolution=',
            'Type=0',
            'Country=0',
            'LabelCode=',
        )),
        newvalue   => (join "\n", (
            'LabelName=Renamed',
            'SortName=Different sort',
            'BeginDate=2001-00-00',
            'EndDate=2002-03-04',
            'Resolution=Swedish folk metal band',
            'Type=2',
            'Country=12',
            'LabelCode=12345'
        )),
    ));
$mocks->expect($mock_sql, 'next_row_hash_ref')->return(undef);
$mocks->expect($mock_sql, 'finish');

my $data = EditMigration->new(c => $c, sql => $mock_sql);

my $edit = $data->get_by_id(1);
isa_ok($edit, 'MusicBrainz::Server::Edit::Historic::EditLabel');

my $upgraded = $edit->upgrade;
isa_ok($upgraded, 'MusicBrainz::Server::Edit::Label::Edit');
is_deeply($upgraded->data, {
    entity_id => 191060,
    old => {
        name       => 'Original name',
        sort_name  => 'Original sort',
        begin_date => { year => undef, month => undef, day => undef },
        end_date   => { year => undef, month => undef, day => undef },
        comment    => undef,
        type_id    => undef,
        country_id => undef,
        label_code => undef,
    },
    new => {
        name       => 'Renamed',
        sort_name  => 'Different sort',
        begin_date => { year => 2001, month => undef, day => undef },
        end_date   => { year => 2002, month => '03', day => '04' },
        comment    => 'Swedish folk metal band',
        type_id    => 2,
        country_id => 12,
        label_code => '12345',
    }
});

done_testing;
