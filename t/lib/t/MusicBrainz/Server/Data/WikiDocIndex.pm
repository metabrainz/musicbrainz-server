package t::MusicBrainz::Server::Data::WikiDocIndex;
use strict;
use warnings;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
