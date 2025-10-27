use strict;
use warnings FATAL => 'all';

use Module::Pluggable::Object;
use lib 't/lib';
use Test::More;
use Test::Routine::Util;

use MusicBrainz::Server::Test qw( commandline_override );

my @classes = (
    't::Sql',
    't::MusicBrainz::DataStore::Redis',
    't::MusicBrainz::DataStore::RedisMulti',
    't::MusicBrainz::Script::RemoveEmptyURLs',
    't::MusicBrainz::Script::RemoveUnreferencedRows',
    't::MusicBrainz::Script::Utils',
    map {
        Module::Pluggable::Object->new( search_path => $_ )->plugins
    } (
        't::MusicBrainz::Server'
    ),
);

MusicBrainz::Server::Test->prepare_test_server;

@classes = commandline_override('t::MusicBrainz::Server::', @classes);

@classes = grep { $_ !~ /(Cover|Event)Art/ } @classes if DBDefs->DISABLE_IMAGE_EDITING;

plan tests => scalar(@classes);
run_tests($_ => $_) for @classes;

1;
