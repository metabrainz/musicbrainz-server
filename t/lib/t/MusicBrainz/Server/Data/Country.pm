package t::MusicBrainz::Server::Data::Country;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;
use Test::Fatal qw( lives_ok );

use MusicBrainz::Server::Data::Country;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+country');

my $country_data = MusicBrainz::Server::Data::Country->new(c => $test->c);
memory_cycle_ok($country_data);

my $country = $country_data->get_by_id(1);
is ( $country->id, 1 );
is ( $country->iso_code, "GB" );
is ( $country->name, "United Kingdom" );

memory_cycle_ok($country_data);
memory_cycle_ok($country);

$country = $country_data->get_by_id(2);
is ( $country->id, 2 );
is ( $country->iso_code, "US" );
is ( $country->name, "United States" );

my $countries = $country_data->get_by_ids(1, 2);
is ( $countries->{1}->id, 1 );
is ( $countries->{1}->iso_code, "GB" );
is ( $countries->{1}->name, "United Kingdom" );

is ( $countries->{2}->id, 2 );
is ( $countries->{2}->iso_code, "US" );
is ( $countries->{2}->name, "United States" );

memory_cycle_ok($country_data);
memory_cycle_ok($countries);

does_ok($country_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @cts = $country_data->get_all;
is(@cts, 2);
is($cts[0]->id, 1);
is($cts[1]->id, 2);

memory_cycle_ok($country_data);
memory_cycle_ok(\@cts);

};

test Cache => sub {

    my $test = shift;
    my $c = $test->cache_aware_c;
    my $cache = $c->cache_manager->_get_cache('memory');

    MusicBrainz::Server::Test->prepare_test_database($c, '+country');

    my @all = $c->model('Country')->get_all;

    is ($all[0]->name, 'United Kingdom');
    is ($all[0]->iso_code, 'GB');

    is ($all[1]->name, 'United States');
    is ($all[1]->iso_code, 'US');

    ok($cache->exists('c:all'), 'cache contains country list');

    # Clear the database connection
    $c = $c->meta->clone_object($c, conn => undef, models => {});

    lives_ok {
        my @all = $c->model('Country')->get_all;

        is ($all[0]->name, 'United Kingdom');
        is ($all[0]->iso_code, 'GB');

        is ($all[1]->name, 'United States');
        is ($all[1]->iso_code, 'US');

    } 'get_all served from cache, not database';

};

1;
