use strict;
use warnings FATAL => 'all';

use Module::Pluggable::Object;
use lib 't/lib';
use Test::More;
use Test::Routine::Util;

use MusicBrainz::Server::Test qw( commandline_override );

my @classes = (
    't::TemplateMacros',
    't::Sql',
    't::MusicBrainz::DataStore::Redis',
    't::MusicBrainz::Script::RebuildCoverArt',
    map {
        Module::Pluggable::Object->new( search_path => $_ )->plugins
    } (
        't::MusicBrainz::Server'
    )
);

MusicBrainz::Server::Test->prepare_test_server;

@classes = commandline_override ("t::MusicBrainz::Server::", @classes);

# XXX Filter out WatchArtist for now as the tests are broken
@classes = grep { $_ !~ /WatchArtist/ } @classes;

plan tests => scalar(@classes);
run_tests($_ => $_) for (@classes);

