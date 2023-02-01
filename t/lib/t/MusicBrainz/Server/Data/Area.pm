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

=head1 DESCRIPTION

This test checks ISO code getters and area contaiment loading.

=cut

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

        note("We run $method($code, 'NA')");
        my $areas = $c->model('Area')->$method($code, 'NA');
        ok(exists $areas->{$code}, "There is an entry for $code");
        ok(exists $areas->{NA}, 'There is an entry for NA');
        is($areas->{NA}, undef, 'The entry for NA contains no area');
        is(
            $areas->{$code}->gid,
            $AREA_GID,
            "The entry for $code contains the expected area",
        );
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

    note('We load the lowest area in the hierarchy');
    my $area = $test->c->model('Area')->get_by_id(1);
    is($area->name, 'descendant', 'Correct basic area is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 4, 'Four levels of containment loaded');
    is(
        $area->containment->[0]->name,
        'parent city',
        'The correct parent city is loaded',
    );
    is(
        $area->containment->[1]->name,
        'parent subdivision',
        'The correct parent subdivision is loaded',
    );
    is(
        $area->containment->[2]->name,
        'parent country',
        'The correct parent country is loaded',
    );
    is(
        $area->containment->[3]->name,
        'parent meta-country',
        'The correct parent meta-country is loaded',
    );

    note('We load the second lowest area in the hierarchy');
    $area = $test->c->model('Area')->get_by_id(2);
    is($area->name, 'parent city', 'Correct basic area is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 3, 'Three levels of containment loaded');
    is(
        $area->containment->[0]->name,
        'parent subdivision',
        'The correct parent subdivision is loaded',
    );
    is(
        $area->containment->[1]->name,
        'parent country',
        'The correct parent country is loaded',
    );
    is(
        $area->containment->[2]->name,
        'parent meta-country',
        'The correct parent meta-country is loaded',
    );

    note('We load the third lowest area in the hierarchy');
    $area = $test->c->model('Area')->get_by_id(3);
    is($area->name, 'parent subdivision', 'Correct basic area is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 2, 'Two levels of containment loaded');
    is(
        $area->containment->[0]->name,
        'parent country',
        'The correct parent country is loaded',
    );
    is(
        $area->containment->[1]->name,
        'parent meta-country',
        'The correct parent meta-country is loaded',
    );

    note('We load the second highest area in the hierarchy');
    $area = $test->c->model('Area')->get_by_id(4);
    is($area->name, 'parent country', 'Correct basic area is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 1, 'One level of containment loaded');
    is(
        $area->containment->[0]->name,
        'parent meta-country',
        'The correct parent meta-country is loaded',
    );

    note('We load the highest area in the hierarchy');
    $area = $test->c->model('Area')->get_by_id(5);
    is($area->name, 'parent meta-country', 'Correct basic area is loaded');

    $test->c->model('Area')->load_containment($area);
    is(scalar @{$area->containment}, 0, 'No levels of containment loaded');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
