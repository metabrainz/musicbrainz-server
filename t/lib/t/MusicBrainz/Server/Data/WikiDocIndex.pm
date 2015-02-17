package t::MusicBrainz::Server::Data::WikiDocIndex;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test;

use MusicBrainz::Server::Data::WikiDocIndex;

with 't::Context';

test all => sub {

my $test = shift;

my $wdi = MusicBrainz::Server::Data::WikiDocIndex->new(
    c => $test->c,
    sql => $test->c->sql
);

$wdi->set_page_version('Test_Page', 123);

my $rev = $wdi->get_page_version('Test_Page');
is($rev, 123);

$rev = $wdi->get_page_version('Test_Page_2');
is($rev, undef);

$wdi->set_page_version('Test_Page_2', 100);

$rev = $wdi->get_page_version('Test_Page_2');
is($rev, 100);

my $index = $wdi->get_index;
is_deeply($index, { 'Test_Page' => 123, 'Test_Page_2' => 100 });

$wdi->set_page_version('Test_Page', undef);

$rev = $wdi->get_page_version('Test_Page');
is($rev, undef);

$index = $wdi->get_index;
is_deeply($index, { 'Test_Page_2' => 100 });

};

1;
