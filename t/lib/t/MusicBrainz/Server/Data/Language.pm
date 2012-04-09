package t::MusicBrainz::Server::Data::Language;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Language;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+language');

my $language_data = MusicBrainz::Server::Data::Language->new(c => $test->c);

my $language = $language_data->get_by_id(1);
is ( $language->id, 1 );
is ( $language->iso_code_3, "deu" );
is ( $language->iso_code_2t, "deu" );
is ( $language->iso_code_2b, "ger" );
is ( $language->iso_code_1, "de" );
is ( $language->name, "German" );

my $languages = $language_data->get_by_ids(1);
is ( $languages->{1}->id, 1 );
is ( $languages->{1}->iso_code_3, "deu" );
is ( $languages->{1}->iso_code_2t, "deu" );
is ( $languages->{1}->iso_code_2b, "ger" );
is ( $languages->{1}->iso_code_1, "de" );
is ( $languages->{1}->name, "German" );

does_ok($language_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @languages = $language_data->get_all;
is(@languages, 1);
is($languages[0]->id, 1);

};

1;
