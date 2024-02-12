package t::MusicBrainz::Server::Data::Role::Collection;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use Test::Routine;
use Test::More;

with 't::Context';

sub create_collection {
    my ($c, $entity_type, $entity_to_add) = @_;

    my $collection = $c->model('Collection')->insert(5, {
        description => '',
        editor_id => 5,
        name => 'Collection123',
        public => 0,
        type_id => $c->sql->select_single_value(
            'SELECT id FROM editor_collection_type WHERE entity_type = ?',
            $entity_type,
        ),
    });
    $c->model('Collection')->add_entities_to_collection(
        $entity_type,
        $collection->{id},
        $entity_to_add->{id},
    );
    return;
}

sub create_insert {
    my ($entity_type, $name) = @_;

    my %row = (name => $name);
    my $entity_properties = $ENTITIES{$entity_type};

    $row{artist_credit} = 1 if $entity_properties->{artist_credits};
    $row{ordering_type_id} = 1 if $entity_type eq 'series';
    $row{release_group_id} = 1 if $entity_type eq 'release';
    $row{sort_name} = $name if $entity_properties->{sort_name};
    $row{type_id} = 1 if $entity_type eq 'series';
    return \%row;
}

for my $entity_type (entities_with('collections')) {
    my $plural = $ENTITIES{$entity_type}{plural};

    test "Deleting $plural that are in a collection" => sub {
        my $test = shift;
        my $c = $test->c;

        MusicBrainz::Server::Test->prepare_test_database($test->c, '+releasegroup');

        $c->sql->do(<<~"SQL");
            INSERT INTO editor (id, name, password, ha1)
                VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
            SELECT setval('${entity_type}_id_seq', 666, FALSE);
            SQL

        my $model = $c->model($ENTITIES{$entity_type}{model});
        my $entity = $model->insert(create_insert($entity_type, 'Test123'));

        create_collection($c, $entity_type, $entity);
        $model->delete($entity->{id});
        ok(!$model->get_by_id($entity->{id}));
    };

    test "Merging $plural that are in a collection" => sub {
        my $test = shift;
        my $c = $test->c;

        MusicBrainz::Server::Test->prepare_test_database($test->c, '+releasegroup');

        $c->sql->do(<<~"SQL");
            INSERT INTO editor (id, name, password, ha1)
                VALUES (5, 'me', '{CLEARTEXT}mb', 'a152e69b4cf029912ac2dd9742d8a9fc');
            SELECT setval('${entity_type}_id_seq', 666, FALSE);
            SQL

        my $model = $c->model($ENTITIES{$entity_type}{model});
        my $entity1 = $model->insert(create_insert($entity_type, 'Test123'));
        my $entity2 = $model->insert(create_insert($entity_type, 'Test456'));

        create_collection($c, $entity_type, $entity1);

        if ($entity_type eq 'release') {
            $model->merge(
                new_id => $entity2->{id},
                old_ids => [$entity1->{id}],
                medium_positions => {},
                merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE,
            );
        } elsif ($entity_type eq 'artist') {
            $model->merge($entity2->{id}, [$entity1->{id}]);
        } else {
            $model->merge($entity2->{id}, $entity1->{id});
        }

        ok($c->sql->select_single_value(
            "SELECT 1 FROM editor_collection_$entity_type WHERE $entity_type = ?",
            $entity2->{id},
        ));
    };
}

1;
