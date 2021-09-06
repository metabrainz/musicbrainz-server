use strict;
use warnings;
use Test::More;

eval 'use Test::EOL';
plan skip_all => 'Test::EOL required' if $@;

use FindBin '$Bin';
use File::Find;

my @files = find(sub {
                     return unless $_ =~ /(.tt|.pm|.t)$/;
                     eol_unix_ok($File::Find::name);
                 }, map { "$Bin/../../$_" } qw( lib root t ) );

done_testing;
