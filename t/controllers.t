use strict;
use warnings FATAL => 'all';

use lib 't/lib';
use MusicBrainz::Server::Test;
use Test::More;
use Test::Routine::Util;
use Try::Tiny;

my $mpo = Module::Pluggable::Object->new(
    search_path => 't::MusicBrainz::Server::Controller');
my @classes = $mpo->plugins;

plan tests => scalar(@classes);
for (@classes) {
    run_tests($_ => $_)
}
