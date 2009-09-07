#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;
use_ok 'MusicBrainz::Server::Data::WikiDocIndex';

my $index_filename;

BEGIN {
    use File::Temp;
    $index_filename = File::Temp::tmpnam();
}

END {
    unlink $index_filename;
}

{
    package TestWikiDocIndex;

    use Moose;
    extends 'MusicBrainz::Server::Data::WikiDocIndex';

    sub _index_file { $index_filename };
}

use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();

open FILE, ">$index_filename";
print FILE "Test_Page=123\n";
close FILE;

my $wdi = TestWikiDocIndex->new( c => $c );

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
