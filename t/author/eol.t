use strict;
use warnings;
use Test::More;

eval 'use Test::EOL';
plan skip_all => 'Test::EOL required' if $@;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
