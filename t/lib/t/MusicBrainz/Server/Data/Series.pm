package t::MusicBrainz::Server::Data::Series;
use Test::Routine;
use Test::More;

with 't::Context';

test 'Items should be ordered by date (MBS-7987)' => sub {
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
        'works are ordered by date'
    );
};

1;
