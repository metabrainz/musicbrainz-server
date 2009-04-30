use strict;
use warnings;
use Test::More tests => 13;
use_ok 'MusicBrainz::Server::Data::Country';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $country_data = MusicBrainz::Server::Data::Country->new(c => $c);

my $country = $country_data->get_by_id(1);
is ( $country->id, 1 );
is ( $country->iso_code, "GB" );
is ( $country->name, "United Kingdom" );

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
