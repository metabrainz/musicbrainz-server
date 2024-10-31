use strict;
use warnings;
use English;
use Test::More;

eval 'use Test::EOL';
plan skip_all => 'Test::EOL required' if $EVAL_ERROR;

use FindBin '$Bin';
use File::Find;

=head1 DESCRIPTION

This test checks whether Perl and TT files have lines that end
with Windows EOL characters rather than Unix ones.

=cut

find(sub {
    return unless $_ =~ /(\.tt|\.pm|\.t)$/;
    eol_unix_ok($File::Find::name);
}, map { "$Bin/../../$_" } qw( lib root t ) );

done_testing;

1;
