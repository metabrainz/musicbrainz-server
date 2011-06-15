use strict;
use warnings FATAL => 'all';

use lib 't/lib';
use MusicBrainz::Server::Test qw( commandline_override );
use Test::More;
use Test::Routine::Util;
use Try::Tiny;

my $mpo = Module::Pluggable::Object->new(
    search_path => 't::MusicBrainz::Server::Controller::WS::2');
my @classes = $mpo->plugins;

@classes = commandline_override ("t::MusicBrainz::Server::Controller::", @classes);

plan tests => scalar(@classes);
run_tests($_ => $_) for (@classes);

