use strict;
use warnings;
use Test::More;

eval 'use Test::NoTabs';
plan skip_all => 'Test::NoTabs required' if $@;

use FindBin '$Bin';
use File::Find;

=head1 DESCRIPTION

This test checks whether Perl and TT files use tabs
when they should use multiple spaces instead.

=cut

find(sub {
    return unless $_ =~ /(\.tt|\.pm|\.t)$/;
    notabs_ok($File::Find::name);
}, map { "$Bin/../../$_" } qw( lib root t ) );

done_testing;
