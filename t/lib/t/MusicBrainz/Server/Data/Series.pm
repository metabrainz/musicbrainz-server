package t::MusicBrainz::Server::Data::Series;
use Test::Routine;
use Test::More;

with 't::Context';

test 'Items should be ordered by relationship date' => sub {
    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $c->sql->do(<<EOSQL);
      INSERT INTO series (id, gid, name, type, ordering_attribute, ordering_type)
        VALUES
          (4, '8658de67-6bb3-4281-be04-1340604ecaae', 'S', 4, 1, 1);

      INSERT INTO work (id, gid, name, type)
        VALUES
          (5, '51922ee8-1023-4341-977e-848e1ea96b07', 'W5', 1),
          (6, '1f9ab3c8-7937-444d-9bf0-9b176a920406', 'W6', 1),
          (7, 'c22690d8-50d7-4428-bac8-ce13c69d37d8', 'W7', 1),
          (8, '6c4c97f4-54ef-4441-85df-c4d2a00517da', 'W8', 1),
          (9, '1ec80148-8943-46c3-a5a0-d587bca15e6e', 'W9', 1);
EOSQL

    $c->model('Relationship')->insert('series', 'work', {
        entity0_id      => 4,
        entity1_id      => 5,
        link_type_id    => 2,
        begin_date      => {year => 1977},
        end_date        => {year => 1995},
    });

    $c->model('Relationship')->insert('series', 'work', {
        entity0_id      => 4,
        entity1_id      => 6,
        link_type_id    => 2,
        begin_date      => undef,
        end_date        => {year => 1995},
    });

    $c->model('Relationship')->insert('series', 'work', {
        entity0_id      => 4,
        entity1_id      => 7,
        link_type_id    => 2,
        begin_date      => {year => 1977},
        end_date        => {year => 2001},
    });

    $c->model('Relationship')->insert('series', 'work', {
        entity0_id      => 4,
        entity1_id      => 8,
        link_type_id    => 2,
        begin_date      => {year => 1979},
        end_date        => undef,
    });

    $c->model('Relationship')->insert('series', 'work', {
        entity0_id      => 4,
        entity1_id      => 9,
        link_type_id    => 2,
        begin_date      => undef,
        end_date        => {year => 1991},
    });

    my $series = $c->model('Series')->get_by_id(4);
    $c->model('SeriesType')->load($series);
    my ($items, $count) = $c->model('Series')->get_entities($series, 5, 0);

    is_deeply(
        [map { $_->{entity}->id } @$items],
        [9, 6, 5, 7, 8],
        'works are ordered by relationship date'
    );
};

test 'Events should be ordered by event date, then name (MBS-7557, MBS-7987)' => sub {
    my $c = shift->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $c->sql->do(<<EOSQL);
      INSERT INTO series (id, gid, name, type, ordering_attribute, ordering_type)
        VALUES
          (4, '8658de67-6bb3-4281-be04-1340604ecaae', 'S', 8, 1, 1);

      INSERT INTO event (id, gid, name, type)
        VALUES
          (1, 'd79a801a-633d-4e08-a313-cd065846a31a', 'E7', 1),
          (2, '1e21b5f0-9826-4fd0-ba73-b977efbcac70', 'E3', 1),
          (3, 'fe1f9bd6-1ecf-4fb2-b2b0-572f411137bd', 'E6', 1),
          (4, 'ca7a4f0f-c666-4498-8d22-c3166c9d79a7', 'E2', 1),
          (5, '98f2b54d-44d7-4421-85b7-c7a3d8e11445', 'E5', 1),
          (6, '2e345567-89d7-45cf-987b-73dc706440d2', 'E1', 1),
          (7, 'c214be92-a6a2-4211-b2ae-a55f9f49227d', 'E4', 1);
EOSQL

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 1,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 2,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 3,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 4,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 5,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 6,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    $c->model('Relationship')->insert('event', 'series', {
        entity0_id      => 7,
        entity1_id      => 4,
        link_type_id    => 4,
    });

    my $series = $c->model('Series')->get_by_id(4);
    $c->model('SeriesType')->load($series);

    my ($items, $count) = $c->model('Series')->get_entities($series, 7, 0);
    is_deeply([map { $_->{entity}->id } @$items], [6, 4, 2, 7, 5, 3, 1], 'events are ordered by name');

    $c->model('Event')->update($_, { name => 'E${_}' }) for (1 .. 7);

    ($items, $count) = $c->model('Series')->get_entities($series, 7, 0);
    is_deeply([map { $_->{entity}->id } @$items], [1, 2, 3, 4, 5, 6, 7], 'events are re-ordered after name changes');

    $c->model('Event')->update(1, { begin_date => { year => 1977 }, end_date => { year => 1995 } });
    $c->model('Event')->update(2, { end_date => { year => 1995 } });
    $c->model('Event')->update(3, { begin_date => { year => 1977 }, end_date => { year => 2001 } });
    $c->model('Event')->update(4, { begin_date => { year => 1979 } });
    $c->model('Event')->update(5, { end_date => { year => 1991 } });
    $c->model('Event')->update(6, { end_date => { year => 1991 }, time => '00:10:00' });
    $c->model('Event')->update(7, { end_date => { year => 1991 }, time => '00:00:00' });

    ($items, $count) = $c->model('Series')->get_entities($series, 7, 0);
    is_deeply([map { $_->{entity}->id } @$items], [5, 7, 6, 2, 1, 3, 4], 'events are ordered by date');

    $c->model('Event')->update(2, { begin_date => { year => 1994 } });
    $c->model('Event')->update(7, { time => '00:20:00' });

    ($items, $count) = $c->model('Series')->get_entities($series, 7, 0);
    is_deeply([map { $_->{entity}->id } @$items], [5, 6, 7, 1, 3, 4, 2], 'events are re-ordered by date after changes');
};

1;
