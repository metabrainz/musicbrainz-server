package t::MusicBrainz::Server::Data::Alias;
use Test::Routine;
use Test::Moose;
use Test::More;

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

BEGIN {
    use MusicBrainz::Server::Data::Artist;
    use MusicBrainz::Server::Data::Label;
    use MusicBrainz::Server::Data::Work;
}

with 't::Context';

sub verify_artist_alias {
    my ($alias, $name, $id, $locale) = @_;
    is($alias->name, $name, "alias name: $name");
    is($alias->artist_id, $id, "artist id: $id");
    is($alias->locale, $locale, "locale: $locale");
}

test all => sub {

    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    $test->c->sql->begin;

    # Artist data should do the alias role
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);
    does_ok($artist_data, 'MusicBrainz::Server::Data::Role::Alias');
    does_ok($artist_data->alias, 'MusicBrainz::Server::Data::Role::Editable');

    # Make sure we can load specific aliases
    my $alias = $artist_data->alias->get_by_id(1);
    ok(defined $alias, 'returns an object');
    isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
    verify_artist_alias($alias, 'Alias 1', 1, undef);

    # Loading the artist from an alias
    $artist_data->load($alias);
    ok(defined $alias->artist, 'didn\'t load artist');
    isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
    is($alias->artist->id, $alias->artist_id, 'loaded artist id');

    # Find all aliases for an artist
    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, "Expected number of aliases");
    verify_artist_alias($alias_set->[0], 'Alias 2', 1, 'en_GB');
    verify_artist_alias($alias_set->[1], 'Alias 1', 1, undef);

    # Attempt finding aliases for an artist with no aliases
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, "Expected lack of aliases found");

    # Make sure we can check if an entity has aliases for a given locale
    ok($artist_data->alias->has_locale(1, 'en_GB'), 'artist #1 has en_GB locale');

    # Test merging aliases together
    $artist_data->alias->merge(1, 2);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 3, "Expected number of aliases");
    is($alias_set->[0]->name, 'Alias 2', 'Original alias #1');
    is($alias_set->[1]->name, 'Alias 1', 'Original alias #2');
    is($alias_set->[2]->name, 'Empty Artist', 'has the old artist as an alias');

    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, 'Merged artist has no aliases');

    # Test merging aliases with identical names
    $artist_data->alias->merge(1, 3);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 4, "Expected number of aliases");
    verify_artist_alias($alias_set->[0], 'Alias 2', 1, 'en_GB');
    verify_artist_alias($alias_set->[1], 'Alias 1', 1, undef);
    verify_artist_alias($alias_set->[2], 'Alias 2', 1, undef);
    verify_artist_alias($alias_set->[3], 'Empty Artist', 1, undef);

    $alias_set = $artist_data->alias->find_by_entity_id(3);
    is(scalar @$alias_set, 0, 'Merged artist has no aliases');

    # Test deleting aliases
    $artist_data->alias->delete_entities(1);
    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 0, 'Artist #1 now has no aliases');

    # Test inserting new aliases
    $artist_data->alias->insert({
                                 artist_id => 1,
                                 name => 'New alias',
                                 sort_name => 'New sort name',
                                 locale => 'en_AU',
                                 primary_for_locale => 0,
                                 ended => 0
                                });

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 1, "Artist #1 has a single newly inserted alias");
    verify_artist_alias($alias_set->[0], 'New alias', 1, 'en_AU');
    is($alias_set->[0]->sort_name, 'New sort name', "sort_name");
    is($alias_set->[0]->primary_for_locale, 0, "primary_for_locale");

    $test->c->sql->commit;

    # Make sure other data types support aliases
    my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);
    does_ok($label_data, 'MusicBrainz::Server::Data::Role::Alias');

    my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);
    does_ok($work_data, 'MusicBrainz::Server::Data::Role::Alias');

};

test 'Merging should not add aliases identical to new name' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'EOSQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', 'Artist 1'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Name', 'Name', 'Artist 2'),
                   (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 'Old name', 'Old name', '');
        EOSQL

    $c->model('Artist')->alias->merge(1, 2, 3);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'has one alias');
    is($aliases->[0]->name, 'Old name', 'has old name alias');
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Merging should not add aliases that already exist' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'EOSQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name) VALUES (1, 'Old name', 'Old name');
        EOSQL

    $c->model('Artist')->alias->merge(1, 2);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'has one alias');
    is($aliases->[0]->name, 'Old name', 'has old name alias',);
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Merging should preserve primary_for_locale' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'EOSQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name, locale, primary_for_locale)
            VALUES (1, 'Old name', 'Old name', 'en_GB', FALSE),
                   (2, 'Foo name', 'Foo name', 'en_GB', TRUE);
        EOSQL

    $c->model('Artist')->alias->merge(1, 2);
    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);

    is(@$aliases, 2, 'has two aliases');

    my @should_be_primary = grep { $_->name eq 'Foo name' } @$aliases;
    is(@should_be_primary, 1, 'has one "Foo name" alias');
    ok(@should_be_primary, 'has "Foo name" alias');
    ok($should_be_primary[0]->primary_for_locale, 'is primary');
    is($should_be_primary[0]->locale, 'en_GB', 'has appropriate locale');

    my @should_be_old = grep { $_->name eq 'Old name' } @$aliases;
    is(@should_be_old, 1, 'has an "Old name" alias');
    ok(!$should_be_old[0]->primary_for_locale, 'is not primary');
    is($should_be_old[0]->locale, 'en_GB', 'has appropriate locale');
};

test 'Multiple aliases with a locale are preserved on merge' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'EOSQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name, locale, primary_for_locale)
            VALUES (1, 'Extra name', 'Extra name', 'en_GB', FALSE),
                   (2, 'Foo name', 'Foo name', 'en_GB', TRUE);
        EOSQL

    $c->model('Artist')->alias->merge(1, 2);
    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);

    is(@$aliases, 3, 'has three aliases (old, foo, extra)');

    my @should_be_primary = grep { $_->name eq 'Foo name' } @$aliases;
    is(@should_be_primary, 1, 'has one "Foo name" alias');
    ok(@should_be_primary, 'has "Foo name" alias');
    ok($should_be_primary[0]->primary_for_locale, 'is primary');
    is($should_be_primary[0]->locale, 'en_GB', 'has appropriate locale');

    my @should_be_old = grep { $_->name eq 'Old name' } @$aliases;
    is(@should_be_old, 1, 'has an "Old name" alias');
    ok(!$should_be_old[0]->primary_for_locale, 'is not primary');
    is($should_be_old[0]->locale, undef, 'has appropriate locale');

    my @should_be_extra = grep { $_->name eq 'Extra name' } @$aliases;
    is(@should_be_extra, 1, 'has an "Extra name" alias');
    ok(!$should_be_extra[0]->primary_for_locale, 'is not primary');
    is($should_be_extra[0]->locale, 'en_GB', 'has appropriate locale');
};

test 'Exists only checks a single entity' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'EOSQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', ''),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name', 'Artist 2'),
                   (3, '1153890e-afdf-404c-85d1-aea98dfe576d', 'Old name', 'Old name', 'Artist 3');
        INSERT INTO artist_alias (artist, name, sort_name)
            VALUES (1, 'Old name', 'Old name'),
                   (2, 'Foo name', 'Foo name');
        EOSQL

    my $check_alias = sub {
        $c->model('Artist')->alias->exists({
            name => shift,
            locale => undef,
            type_id => undef,
            not_id => undef,
            entity => shift})
      };

    ok($check_alias->('Old name', 1), 'Old name aliased to artist #1');
    ok(!$check_alias->('Foo name', 1), 'Foo name NOT aliased to artist #1');

    ok(!$check_alias->('Old name', 2), 'Old name NOT aliased to artist #2');
    ok($check_alias->('Foo name', 2), 'Foo name aliased to artist #2');

    ok(!$check_alias->('Old name', 3), 'Old name NOT aliased to artist #3');
    ok(!$check_alias->('Foo name', 3), 'Foo name NOT aliased to artist #3');
};

1;
