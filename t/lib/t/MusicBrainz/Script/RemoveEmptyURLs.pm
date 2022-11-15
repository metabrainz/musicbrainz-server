package t::MusicBrainz::Script::RemoveEmptyURLs;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

use MusicBrainz::Script::RemoveEmpty;

with 't::Context';

=head1 DESCRIPTION

This test checks whether the RemoveEmpty script is working as expected
for URLS, deleting only URLs that are unused, not new,
and have no pending edits.

=cut

test 'The RemoveEmpty script deletes the expected URLs' => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+url');

my $sql = $c->sql;
is($sql->select_single_value('SELECT COUNT(*) FROM url'),
   5,
   'Five URLs exist before the script is run');


my $script = MusicBrainz::Script::RemoveEmpty->new( c => $c );
ok !exception { $script->run('url') };

is($sql->select_single_value('SELECT COUNT(*) FROM url'),
   4,
   'Four URLs exist after the script is run, one has been deleted');

is($sql->select_single_value('SELECT 1 FROM url WHERE id = 2'),
   1,
   'Recently updated unused URL has not been deleted');

is($sql->select_single_value('SELECT 1 FROM url WHERE id = 5'),
   1,
   'Unused URL with pending edits has not been deleted');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
