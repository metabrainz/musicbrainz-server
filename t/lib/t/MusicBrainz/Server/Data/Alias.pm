package t::MusicBrainz::Server::Data::Alias;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_deeply );

use DateTime;
use List::AllUtils qw( first );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

BEGIN {
    use MusicBrainz::Server::Data::Artist;
    use MusicBrainz::Server::Data::Label;
    use MusicBrainz::Server::Data::Work;
}

with 't::Context';

=head1 DESCRIPTION

This test checks alias loading, alias editing (inserting, updating and
removing, including changing primary aliases) and the effects of
merging entities with aliases.

It also checks that instrument alias editing invalidates the attribute
caches.

=cut

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

test 'The right roles are set' => sub {
    my $test = shift;

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    does_ok(
        $artist_data,
        'MusicBrainz::Server::Data::Role::Alias',
        'Artists support aliases',
    );

    my $label_data = MusicBrainz::Server::Data::Label->new(c => $test->c);
    does_ok(
        $label_data,
        'MusicBrainz::Server::Data::Role::Alias',
        'Labels support aliases',
    );

    my $work_data = MusicBrainz::Server::Data::Work->new(c => $test->c);
    does_ok(
        $work_data,
        'MusicBrainz::Server::Data::Role::Alias',
        'Works support aliases',
    );

    does_ok(
        $artist_data->alias,
        'MusicBrainz::Server::Data::Role::PendingEdits',
        'Aliases can have pending edits',
    );
};

test 'Loading aliases and alias artists' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    note('We use get_by_id to load the alias with id 1');
    my $alias = $artist_data->alias->get_by_id(1);
    ok(defined $alias, 'An object is loaded');
    isa_ok(
        $alias,
        'MusicBrainz::Server::Entity::ArtistAlias',
        'The loaded object',
    );
    verify_artist_alias($alias, 'Alias 1', 'Alias 1', 1, undef, 0);

    note('We use artist_data->load to load the artist for the alias');
    $artist_data->load($alias);
    ok(defined $alias->artist, 'An artist object is loaded');
    isa_ok(
        $alias->artist,
        'MusicBrainz::Server::Entity::Artist',
        'The loaded object',
    );
    is(
        $alias->artist->id,
        $alias->artist_id,
        'The loaded artist id matches the expected one',
    );
};

test 'Finding aliases for an artist ID' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    note('We use find_by_entity_id to load the aliases for an artist with some');
    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'We get the expected number of aliases back');
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

    note('We use find_by_entity_id to load the aliases for an artist with none');
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, 'We get no aliases back');
};

test 'Test has_locale' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    ok(
        $artist_data->alias->has_locale(1, 'en_GB'),
        'Artist 1 has an alias with en_GB locale',
    );
    ok(
        !$artist_data->alias->has_locale(2, 'en_GB'),
        'Artist 2 has no alias with en_GB locale',
    );
};

test 'Test delete_entities' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Artist 1 has two aliases');

    note('We use delete_entities on Artist 1');
    $artist_data->alias->delete_entities(1);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 0, 'Artist 1 now has no aliases');
};


test 'Adding and updating aliases, with primary for locale updates' => sub {

    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    $test->c->sql->begin;

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    note('We try inserting a new, primary alias');
    my $alias = $artist_data->alias->insert({
                                 artist_id => 2,
                                 name => 'New alias',
                                 sort_name => 'New sort name',
                                 locale => 'en_AU',
                                 primary_for_locale => 1,
                                 ended => 0,
                                });
    my $alias_id = $alias->{id};
    my $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(
        scalar @$alias_set,
        1,
        'The artist has a single, newly inserted alias',
    );
    verify_artist_alias(
        $alias_set->[0],
        'New alias', 'New sort name', 2, 'en_AU', 1,
        'The alias data matches the inserted data',
    );

    note('We try inserting another primary alias for the same locale');
    my $alias2 = $artist_data->alias->insert({
                                 artist_id => 2,
                                 name => 'Newer alias',
                                 sort_name => 'Newer sort name',
                                 locale => 'en_AU',
                                 primary_for_locale => 1,
                                 ended => 0,
                                });
    my $alias2_id = $alias2->{id};
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 2, 'The artist has two aliases');
    verify_artist_alias(
        $alias_set->[0],
        'Newer alias', 'Newer sort name', 2, 'en_AU', 1,
        'The new primary alias is the newly inserted alias and has the expected data',
    );
    verify_artist_alias(
        $alias_set->[1],
        'New alias', 'New sort name', 2, 'en_AU', 0,
        'The old alias is still present, but is no longer marked as the primary',
    );

    note('We try updating the original alias to set it as primary again');
    $artist_data->alias->update($alias_id, {primary_for_locale => 1});
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 2, 'The artist still has two aliases');
    verify_artist_alias(
        $alias_set->[0],
        'New alias', 'New sort name', 2, 'en_AU', 1,
        'The old alias is still present, and marked as the primary again',
    );
    verify_artist_alias(
        $alias_set->[1],
        'Newer alias', 'Newer sort name', 2, 'en_AU', 0,
        'The newer alias is still present, but is no longer marked as the primary',
    );

    note('We add a third alias, primary for a different locale');
    my $alias3 = $artist_data->alias->insert({
                                 artist_id => 2,
                                 name => 'New US alias',
                                 sort_name => 'New US sort name',
                                 locale => 'en_US',
                                 primary_for_locale => 1,
                                 ended => 0,
                                });
    my $alias3_id = $alias3->{id};
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 3, 'The artist now has three aliases');

    note('We try updating the new alias to have the same locale as the rest');
    $artist_data->alias->update($alias3_id, {locale => 'en_AU'});
    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 3, 'The artist still has three aliases');
    my $updated_alias2 = first { $_->id == $alias2_id } @$alias_set;
    my $updated_alias3 = first { $_->id == $alias3_id } @$alias_set;
    verify_artist_alias(
        $updated_alias2,
        'Newer alias', 'Newer sort name', 2, 'en_AU', 0,
        'The previous primary alias is no longer marked as primary',
    );
    verify_artist_alias(
        $updated_alias3,
        'New US alias', 'New US sort name', 2, 'en_AU', 1,
        'The changed alias has the updated locale and is marked as primary',
    );

    $test->c->sql->commit;
};

test 'Merging artists correctly merges their aliases' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Artist 1 has two aliases');

    $alias_set = $artist_data->alias->find_by_entity_id(2);
    is(scalar @$alias_set, 0, 'Artist 2 has no aliases');

    note('We merge artist 2 into artist 1');
    $artist_data->alias->merge(1, 2);

    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 3, 'The merged artist has 3 aliases');
    verify_artist_alias(
        $alias_set->[0],
        'Alias 2', 'Alias 2', 1, 'en_GB', 0,
        'The old alias with a locale has been kept and still sorts first',
    );
    verify_artist_alias(
        $alias_set->[1],
        'Alias 1', 'Alias 1', 1, undef, 0,
        'The old alias without a locale has been kept',
    );
    verify_artist_alias(
        $alias_set->[2],
        'Empty Artist', 'Empty Artist', 1, undef, 0,
        'The artist name of artist 2 has been added as an alias',
    );
};

test 'Merging artist aliases works even if aliases have the same name' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+artistalias');

    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $test->c);

    my $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 2, 'Artist 1 has two aliases');

    $alias_set = $artist_data->alias->find_by_entity_id(3);
    is(scalar @$alias_set, 1, 'Artist 3 has one alias');

    note('We merge artist 2 into artist 1');
    $artist_data->alias->merge(1, 3);

    $alias_set = $artist_data->alias->find_by_entity_id(1);
    is(scalar @$alias_set, 3, 'Expected number of aliases');
    verify_artist_alias(
        $alias_set->[0], 'Alias 2', 'Alias 2', 1, 'en_GB', 0,
        'The old alias with a locale has been kept and still sorts first',
    );
    verify_artist_alias(
        $alias_set->[1],
        'Alias 1', 'Alias 1', 1, undef, 0,
        'The old alias without a locale has been kept',
    );
    verify_artist_alias(
        $alias_set->[2],
        'Alias 2', 'Alias 2', 1, undef, 0,
        'The artist 3 alias with the same name as the locale alias, but without a locale, has been kept and sorts last',
    );

    $alias_set = $artist_data->alias->find_by_entity_id(3);
    is(
        scalar @$alias_set,
        0,
        'The merged artist has no aliases anymore',
    );
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

    note('We merge two artists into a third, but one has the same name as the destination');
    $c->model('Artist')->alias->merge(1, 2, 3);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'The artist has one alias');
    is(
        $aliases->[0]->name,
        'Old name',
        'It is the one not matching its name',
    );
    ok(
        !(grep { $_->name eq 'Name' } @$aliases),
        'It has no alias matching its name',
    );
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

    note('We merge an artist into another that already has an alias of the same name');
    $c->model('Artist')->alias->merge(1, 2);

    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);
    is(@$aliases, 1, 'The artist still has one alias');
    is($aliases->[0]->name, 'Old name', 'It is the expected alias');
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

    note('We merge an artist with a primary alias into one with a non-primary one');
    $c->model('Artist')->alias->merge(1, 2);
    my $aliases = $c->model('Artist')->alias->find_by_entity_id(1);

    is(@$aliases, 2, 'The merged artist has two aliases');

    my @should_be_primary = grep { $_->name eq 'Foo name' } @$aliases;
    is(@should_be_primary, 1, 'The merged alias is there');
    ok($should_be_primary[0]->primary_for_locale, 'Is still primary');
    is($should_be_primary[0]->locale, 'en_GB', 'Has the appropriate locale');

    my @should_be_old = grep { $_->name eq 'Old name' } @$aliases;
    is(@should_be_old, 1, 'The old alias is there');
    ok(!$should_be_old[0]->primary_for_locale, 'Is still not primary');
    is($should_be_old[0]->locale, 'en_GB', 'Has the appropriate locale');
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

    is(@$aliases, 3, 'The artist has three aliases (old, foo, extra)');

    my @should_be_primary = grep { $_->name eq 'Foo name' } @$aliases;
    is(@should_be_primary, 1, 'There is one "Foo name" alias');
    ok($should_be_primary[0]->primary_for_locale, 'Is primary');
    is($should_be_primary[0]->locale, 'en_GB', 'Has the appropriate locale');

    my @should_be_old = grep { $_->name eq 'Old name' } @$aliases;
    is(@should_be_old, 1, 'There is one "Old name" alias');
    ok(!$should_be_old[0]->primary_for_locale, 'Is not primary');
    is($should_be_old[0]->locale, undef, 'Has the appropriate locale');

    my @should_be_extra = grep { $_->name eq 'Extra name' } @$aliases;
    is(@should_be_extra, 1, 'There is one "Extra name" alias');
    ok(!$should_be_extra[0]->primary_for_locale, 'Is not primary');
    is($should_be_extra[0]->locale, 'en_GB', 'Has the appropriate locale');
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
