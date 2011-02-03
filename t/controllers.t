use strict;
use warnings FATAL => 'all';

use lib 't/lib';
use MusicBrainz::Server::Test;
use Test::More;
use Test::Routine::Util;
use Try::Tiny;

my $mpo = Module::Pluggable::Object->new(
    search_path => 't::MusicBrainz::Server::Controller::Artist');
my @classes = $mpo->plugins;

for (@classes) {
    run_tests($_ => $_)
}

done_testing;
