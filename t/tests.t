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
    map {
        Module::Pluggable::Object->new( search_path => $_ )->plugins
    } (
        't::MusicBrainz::Server'
    )
);

MusicBrainz::Server::Test->prepare_test_server;

@classes = commandline_override('t::MusicBrainz::Server::', @classes);

# XXX Filter out WatchArtist for now as the tests are broken
@classes = grep { $_ !~ /WatchArtist/ } @classes;

plan tests => scalar(@classes);
run_tests($_ => $_) for @classes;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
