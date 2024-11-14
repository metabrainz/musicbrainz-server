package t::MusicBrainz::Server::Data::Alias;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_deeply );

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
    my ($alias, $name, $sort_name, $id, $locale, $primary_for_locale, $message) = @_;
    ok(
        is($alias->name, $name, "Alias name is $name") &&
        is($alias->sort_name, $sort_name, "Alias sort name is $sort_name") &&
        is($alias->artist_id, $id, "Artist ID for the alias is $id") &&
        is(
            $alias->locale,
            $locale,
            $locale ? "Alias locale is $locale" : 'Alias locale is undef',
        ) &&
        is(
            $alias->primary_for_locale,
            $primary_for_locale,
            $primary_for_locale
                ? 'Alias is marked as primary'
                : 'Alias is not marked as primary',
        ),

        $message || 'Alias data matches the expectation',
    );
}

test all => sub {

    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    $test->c->sql->begin;

    # Artist data should do the alias role
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);
    does_ok($artist_data, 'MusicBrainz::Server::Data::Role::Alias');
    does_ok($artist_data->alias, 'MusicBrainz::Server::Data::Role::PendingEdits');

    # Make sure we can load specific aliases
    my $alias = $artist_data->alias->get_by_id(1);
    ok(defined $alias, 'returns an object');
    isa_ok($alias, 'MusicBrainz::Server::Entity::ArtistAlias', 'not an artist alias');
    verify_artist_alias($alias, 'Alias 1', 'Alias 1', 1, undef, 0);

    # Loading the artist from an alias
    $artist_data->load($alias);
    ok(defined $alias->artist, q(didn't load artist));
    isa_ok($alias->artist, 'MusicBrainz::Server::Entity::Artist', 'not an artist object');
    is($alias->artist->id, $alias->artist_id, 'loaded artist id');

    # Find all aliases for an artist
    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Expected number of aliases');
    verify_artist_alias(
        $alias_set->[0],
        'Alias 2', 'Alias 2', 1, 'en_GB', 0,
        'The alias with a locale sorts first and has the expected data',
    );
    verify_artist_alias(
        $alias_set->[1],
        'Alias 1', 'Alias 1', 1, undef, 0,
        'The alias without a locale sorts last and has the expected data',
    );

    # Attempt finding aliases for an artist with no aliases
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, 'Expected lack of aliases found');

    # Make sure we can check if an entity has aliases for a given locale
    ok($artist_data->alias->has_locale(1, 'en_GB'), 'artist #1 has en_GB locale');

    # Test merging aliases together
    $artist_data->alias->merge(1, 2);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 3, 'Expected number of aliases');
    is($alias_set->[0]->name, 'Alias 2', 'Original alias #1');
    is($alias_set->[1]->name, 'Alias 1', 'Original alias #2');
    is($alias_set->[2]->name, 'Empty Artist', 'has the old artist as an alias');

    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, 'Merged artist has no aliases');

    # Test merging aliases with identical names
    $artist_data->alias->merge(1, 3);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 4, 'Expected number of aliases');
    verify_artist_alias($alias_set->[0], 'Alias 2', 'Alias 2', 1, 'en_GB', 0);
    verify_artist_alias($alias_set->[1], 'Alias 1', 'Alias 1', 1, undef, 0);
    verify_artist_alias($alias_set->[2], 'Alias 2', 'Alias 2', 1, undef, 0);
    verify_artist_alias(
        $alias_set->[3],
        'Empty Artist', 'Empty Artist', 1, undef, 0,
    );

    $alias_set = $artist_data->alias->find_by_entity_id(3);
    is(scalar @$alias_set, 0, 'Merged artist has no aliases');

    # Test deleting aliases
    $artist_data->alias->delete_entities(1);
    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 0, 'Artist #1 now has no aliases');

    # Test inserting new aliases
    my $alias2 = $artist_data->alias->insert({
                                 artist_id => 1,
                                 name => 'New alias',
                                 sort_name => 'New sort name',
                                 locale => 'en_AU',
                                 primary_for_locale => 1,
                                 ended => 0,
                                });
    my $alias_id = $alias2->{id};
    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 1, 'Artist #1 has a single newly inserted alias');
    verify_artist_alias(
        $alias_set->[0],
        'New alias', 'New sort name', 1, 'en_AU', 1,
    );

    # Test overriding primary for locale on insert
    $artist_data->alias->insert({
                                 artist_id => 1,
                                 name => 'Newer alias',
                                 sort_name => 'Newer sort name',
                                 locale => 'en_AU',
                                 primary_for_locale => 1,
                                 ended => 0,
                                });
    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Artist #1 has a second newly inserted alias');
    verify_artist_alias(
        $alias_set->[0],
        'Newer alias', 'Newer sort name', 1, 'en_AU', 1,
        'The new (primary) alias is the newly inserted alias and has the expected data',
    );
    is(
        $alias_set->[1]->primary_for_locale,
        0,
        'Other (old) alias is no longer primary_for_locale',
    );

    # Test overriding primary for locale on update
    $artist_data->alias->update($alias_id, {primary_for_locale => 1});
    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Artist #1 still has two aliases');
    is($alias_set->[1]->primary_for_locale,
       0,
       'new alias is no longer primary_for_locale');
    is($alias_set->[0]->primary_for_locale,
       1,
       'old alias is again primary_for_locale');

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

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', 'Artist 1'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Name', 'Name', 'Artist 2'),
                   (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 'Old name', 'Old name', '');
        SQL

    $c->model('Artist')->alias->merge(1, 2, 3);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'has one alias');
    is($aliases->[0]->name, 'Old name', 'has old name alias');
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Merging should not add aliases that already exist' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name) VALUES (1, 'Old name', 'Old name');
        SQL

    $c->model('Artist')->alias->merge(1, 2);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'has one alias');
    is($aliases->[0]->name, 'Old name', 'has old name alias',);
    ok(!(grep { $_->name eq 'Name' } @$aliases), 'does not have new name alias');
};

test 'Merging should preserve primary_for_locale' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name, locale, primary_for_locale)
            VALUES (1, 'Old name', 'Old name', 'en_GB', FALSE),
                   (2, 'Foo name', 'Foo name', 'en_GB', TRUE);
        SQL

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

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name'),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name');
        INSERT INTO artist_alias (artist, name, sort_name, locale, primary_for_locale)
            VALUES (1, 'Extra name', 'Extra name', 'en_GB', FALSE),
                   (2, 'Foo name', 'Foo name', 'en_GB', TRUE);
        SQL

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

    $c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name, comment)
            VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 'Name', 'Name', ''),
                   (2, '73371ea0-7217-11de-8a39-0800200c9a66', 'Old name', 'Old name', 'Artist 2'),
                   (3, '1153890e-afdf-404c-85d1-aea98dfe576d', 'Old name', 'Old name', 'Artist 3');
        INSERT INTO artist_alias (artist, name, sort_name)
            VALUES (1, 'Old name', 'Old name'),
                   (2, 'Foo name', 'Foo name');
        SQL

    my $check_alias = sub {
        $c->model('Artist')->alias->exists({
            name => shift,
            locale => undef,
            type_id => undef,
            not_id => undef,
            entity => shift});
      };

    ok($check_alias->('Old name', 1), 'Old name aliased to artist #1');
    ok(!$check_alias->('Foo name', 1), 'Foo name NOT aliased to artist #1');

    ok(!$check_alias->('Old name', 2), 'Old name NOT aliased to artist #2');
    ok($check_alias->('Foo name', 2), 'Foo name aliased to artist #2');

    ok(!$check_alias->('Old name', 3), 'Old name NOT aliased to artist #3');
    ok(!$check_alias->('Foo name', 3), 'Foo name NOT aliased to artist #3');
};

test 'Modifying instrument aliases invalidates the link attribute type caches' => sub {
    my $test = shift;
    my $c = $test->c;

    my $piano_lat_id = 180;
    my $piano_via_all;

    # Note: This test only checks that the `get_all` cache is invalidated,
    # since we only use instrument aliases from that cache. We don't
    # currently invalidate the `get_by_id` cache.

    my $fetch_piano = sub {
        ($piano_via_all) = grep {
            $_->id == $piano_lat_id
        } $c->model('LinkAttributeType')->get_all;
    };

    $fetch_piano->();
    cmp_deeply($piano_via_all->instrument_aliases, ['Klavier']);

    my $foo_alias = $c->model('Instrument')->alias->insert({
        instrument_id => 137,
        locale => 'en',
        primary_for_locale => 1,
        name => 'Foo',
        sort_name => 'Foo',
        type => 1,
        ended => 1,
        begin_date => undef,
        end_date => undef,
    });

    $fetch_piano->();
    cmp_deeply(
        $piano_via_all->instrument_aliases,
        ['Foo', 'Klavier'],
        'link_attribute_type:all cache is updated after instrument alias insertion',
    );

    $c->model('Instrument')->alias->update($foo_alias->id, {
        name => 'Foo!',
    });

    $fetch_piano->();
    cmp_deeply(
        $piano_via_all->instrument_aliases,
        ['Foo!', 'Klavier'],
        'link_attribute_type:all cache is updated after instrument alias update',
    );

    $c->model('Instrument')->alias->delete($foo_alias->id);

    $fetch_piano->();
    cmp_deeply(
        $piano_via_all->instrument_aliases,
        ['Klavier'],
        'link_attribute_type:all cache is updated after instrument alias deletion',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
