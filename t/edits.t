use strict;
use warnings FATAL => 'all';

use lib 't/lib';
use MusicBrainz::Server::Test qw( commandline_override );
use Test::More;
use Test::Routine::Util;
use Try::Tiny;

my $mpo = Module::Pluggable::Object->new(
    search_path => 't::MusicBrainz::Server::Edit');
my @classes = $mpo->plugins;

push @classes, 't::MusicBrainz::Server::EditRegistry';

@classes = commandline_override ("t::MusicBrainz::Server::Edit", @classes);

plan tests => scalar(@classes);
run_tests($_ => $_) for (@classes);

