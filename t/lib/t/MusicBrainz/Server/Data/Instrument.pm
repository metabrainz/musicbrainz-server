package t::MusicBrainz::Server::Data::Instrument;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::Instrument;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Search;
use MusicBrainz::Server::Test;
use Sql;

with 't::Edit';
with 't::Context';

test 'Load basic data' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+data_instrument');

    my $instrument_data = $test->c->model('Instrument');
    does_ok($instrument_data, 'MusicBrainz::Server::Data::Role::Editable');

    # ----
    # Test fetching instruments:

    # An instrument with all attributes populated
    my $instrument = $instrument_data->get_by_id(3);
    is( $instrument->id, 3, 'loaded full instrument correctly from DB');
    is( $instrument->gid, '745c079d-374e-4436-9448-da92dedef3ce', 'loaded full instrument correctly from DB' );
    is( $instrument->name, 'Test Instrument', 'loaded full instrument correctly from DB' );
    is( $instrument->type_id, 2, 'loaded full instrument correctly from DB' );
    is( $instrument->edits_pending, 0, 'loaded full instrument correctly from DB' );
    is( $instrument->comment, 'Yet Another Test Instrument', 'loaded full instrument correctly from DB' );
    is( $instrument->description, 'This is a description!', 'loaded full instrument correctly from DB' );

    # An instrument with the minimal set of required attributes
    $instrument = $instrument_data->get_by_id(4);
    is( $instrument->id, 4, 'loaded minimal instrument correctly from DB' );
    is( $instrument->gid, '945c079d-374e-4436-9448-da92dedef3cf', 'loaded minimal instrument correctly from DB' );
    is( $instrument->name, 'Minimal Instrument', 'loaded minimal instrument correctly from DB' );
    is( $instrument->type_id, undef, 'loaded minimal instrument correctly from DB' );
    is( $instrument->edits_pending, 0, 'loaded minimal instrument correctly from DB' );
    is( $instrument->comment, '', 'loaded minimal instrument correctly from DB' );
    is( $instrument->description, '', 'loaded minimal instrument correctly from DB' );
};

test 'Create, update, delete instruments' => sub {
    my $test = shift;
    my $c = $test->cache_aware_c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+data_instrument');

    my $instrument_data = $c->model('Instrument');

    my $type_info_key = 'js_link_attribute_type_info';
    $c->cache->set($type_info_key, '123');
    $c->cache->set("$type_info_key:etag", '456');

    is($c->cache->get($type_info_key), '123', 'type-info cache key is set');
    is($c->cache->get("$type_info_key:etag"), '456', 'type-info etag cache key is set');

    my $instrument = $instrument_data->insert({
            name => 'New Instrument',
            comment => 'Instrument comment',
            type_id => 1,
        });
    ok($instrument->{id} > 4);

    # MBS-12629: Adding new instrument doesn't clear type-info cache
    is($c->cache->get($type_info_key), undef, 'type-info cache key is cleared');
    is($c->cache->get("$type_info_key:etag"), undef, 'type-info etag cache key is cleared');

    $instrument = $instrument_data->get_by_id($instrument->{id});
    is($instrument->name, 'New Instrument', 'newly-created instrument is correct');
    is($instrument->type_id, 1, 'newly-created instrument is correct');
    is($instrument->comment, 'Instrument comment', 'newly-created instrument is correct');
    is($instrument->description, '', 'newly-created instrument is correct');
    ok(defined $instrument->gid, 'newly-created instrument has an MBID');
    ok($c->sql->select_single_value('SELECT TRUE FROM link_attribute_type WHERE gid = ?', $instrument->gid),
       'link_attribute_type row was inserted too');

    # ---
    # Updating instruments
    $instrument_data->update($instrument->id, {
            name => 'Updated Instrument',
            type_id => undef,
            comment => 'Updated comment',
            description => 'Newly-created description'
        });


    $instrument = $instrument_data->get_by_id($instrument->id);
    is($instrument->name, 'Updated Instrument', 'updated instrument data is correct');
    is($instrument->type_id, undef, 'updated instrument data is correct');
    is($instrument->comment, 'Updated comment', 'updated instrument data is correct');
    is($instrument->description, 'Newly-created description', 'updated instrument data is correct');
    is($c->sql->select_single_value('SELECT description FROM link_attribute_type WHERE gid = ?', $instrument->gid),
       'Newly-created description',
       'link_attribute_type row was updated');

    my $gid = $instrument->gid;
    $instrument_data->delete($instrument->id);
    $instrument = $instrument_data->get_by_id($instrument->id);
    ok(!defined $instrument, 'instrument was deleted');
    ok(!defined $c->sql->select_single_value('SELECT TRUE FROM link_attribute_type WHERE gid = ?', $gid),
       'link_attribute_type row was deleted too');
};

test 'Merge instruments' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+data_instrument');

    my $instrument_data = $c->model('Instrument');
    $instrument_data->merge(3 => (4) );

    my $instrument = $instrument_data->get_by_id(4);
    ok(!defined $instrument);
    is($c->sql->select_single_value('SELECT id FROM link_attribute_type WHERE gid = ?', '945c079d-374e-4436-9448-da92dedef3cf'),
       undef, 'No link_attribute_type exists for merged-away instrument');

    $instrument = $instrument_data->get_by_id(3);
    ok(defined $instrument);
    is($instrument->name, 'Test Instrument');
    ok($c->sql->select_single_value('SELECT id FROM link_attribute_type WHERE gid = ?', $instrument->gid),
       'Still have a link_attribute_type row for merged-into instrument');

    my $recording = $c->model('Recording')->get_by_id(1);
    $c->model('Relationship')->load($recording);
    my $attributes = $recording->relationships->[0]->link->attributes;

    cmp_bag(
        [
            {
                type_gid => $attributes->[0]->type->gid,
                credited_as => $attributes->[0]->credited_as
            },
            {
                type_gid => $attributes->[1]->type->gid,
                credited_as => $attributes->[1]->credited_as
            }
        ],
        [
            {
                type_gid => '745c079d-374e-4436-9448-da92dedef3ce',
                credited_as => 'blah instrument'
            },
            # Test that other attribute on the link didn't change.
            {
                type_gid => 'a56d18ae-485f-5547-a559-eba3efef04d0',
                credited_as => 'stupid instrument'
            }
        ]
    );
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
