use strict;
use warnings FATAL => 'all';

use lib 't/lib';
use MusicBrainz::Server::Test;
use Test::More;
use Test::Routine::Util;
use Try::Tiny;

my $mpo = Module::Pluggable::Object->new(
    search_path => 't::MusicBrainz::Server::Edit');
my @classes = $mpo->plugins;

for ($mpo->plugins) {
    run_tests($_ => $_)
}

done_testing;
