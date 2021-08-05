use strict;
use warnings;
use Test::More;

eval 'use Test::NoTabs';
plan skip_all => 'Test::NoTabs required' if $@;

use FindBin '$Bin';
use File::Find;

my @files = find(sub {
                     return unless $_ =~ /(.tt|.pm|.t)$/;
                     notabs_ok($File::Find::name);
                 }, map { "$Bin/../../$_" } qw( lib root t ) );

done_testing;
