package t::MusicBrainz::Server::Data::Area;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Test;

with 't::Edit';
with 't::Context';

my $AREA_GID = 'f03dd94f-a936-42eb-bb97-819102487899';
my $INSERT_AREA = <<~"SQL";
    INSERT INTO area (id, gid, name)
        VALUES (1, '$AREA_GID', 'Area');
    SQL

for my $test_data (
    [ 'iso_3166_1', 'CO' ],
    [ 'iso_3166_2', 'US-MD' ],
    [ 'iso_3166_3', 'DDDE' ],
) {
    my ($iso, $code) = @$test_data;
    my $method = "get_by_$iso";

    test $method => sub {
        my $test = shift;
        my $c = $test->c;

        $c->sql->do(<<~"SQL");
            $INSERT_AREA
            INSERT INTO $iso (area, code) VALUES (1, '$code');
            SQL

        my $areas = $c->model('Area')->$method($code, 'NA');
        ok(exists $areas->{$code}, "Found an area for $code");
        ok(exists $areas->{NA}, 'There is an entry for NA');
        is($areas->{NA}, undef, 'No area for NA');
        is($areas->{$code}->gid, $AREA_GID, "Found $code area");
    };
}

test 'Test load_containment' => sub {
    my $test = shift;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO area (id, gid, name, type)
            VALUES (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'descendant', 5),
                   (2, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbaaaa', 'parent city', 3),
                   (3, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbcccc', 'parent subdivision', 2),
                   (4, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'parent country', 1),
                   (5, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'parent meta-country', 1);

        INSERT INTO link (id, link_type) VALUES (1, 356);
        INSERT INTO l_area_area (link, entity0, entity1)
            VALUES (1, 2, 1), (1, 3, 2), (1, 4, 3), (1, 5, 4);
        SQL

    my $area = $test->c->model('Area')->get_by_id(1);
    is($area->name, 'descendant', 'correct descendant country is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 4);
    is($area->containment->[0]->name, 'parent city', 'correct parent city is loaded');
    is($area->containment->[1]->name, 'parent subdivision', 'correct parent subdivision is loaded');
    is($area->containment->[2]->name, 'parent country', 'correct parent country is loaded');
    is($area->containment->[3]->name, 'parent meta-country', 'parent meta-country is loaded');

    $area = $test->c->model('Area')->get_by_id(2);
    is($area->name, 'parent city', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 3);
    is($area->containment->[0]->name, 'parent subdivision', 'correct parent subdivision is loaded');
    is($area->containment->[1]->name, 'parent country', 'correct parent country is loaded');
    is($area->containment->[2]->name, 'parent meta-country', 'parent meta-country is loaded');

    $area = $test->c->model('Area')->get_by_id(3);
    is($area->name, 'parent subdivision', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 2);
    is($area->containment->[0]->name, 'parent country', 'correct parent country is loaded');
    is($area->containment->[1]->name, 'parent meta-country', 'parent meta-country is loaded');

    $area = $test->c->model('Area')->get_by_id(4);
    is($area->name, 'parent country', 'correct descendant is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 1);
    is($area->containment->[0]->name, 'parent meta-country', 'correct parent meta-country is loaded');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
