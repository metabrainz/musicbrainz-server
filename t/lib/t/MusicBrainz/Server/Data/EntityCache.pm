package t::MusicBrainz::Server::Data::EntityCache;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use MusicBrainz::Server::Context;

with 't::Context';

test all => sub {
    my $test = shift;
    my $c = $test->c;
    my $sql = $c->sql;
    my $cache = $c->cache('artist');
    my $artist_data = $c->model('Artist');

    $sql->auto_commit(1);
    $sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (3, 'e7717242-d43f-46e0-b5ef-9a46ca4d458a', 'Test', 'Test');
        SQL

    ok(!$cache->exists('artist:3'),
       'artist is not in the cache');

    $sql->begin;
    my $artist = $artist_data->get_by_id(3);
    $sql->commit;

    is($artist->id, 3,
       'get_by_id returns artist with id=3 before caching');
    ok($cache->get('artist:3')->isa('MusicBrainz::Server::Entity::Artist'),
       'cache contains artist for id');

    $sql->begin;
    $artist = $artist_data->get_by_id(3);
    $sql->commit;

    is($artist->id, 3,
       'get_by_id returns artist with id=3 after caching');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
