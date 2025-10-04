package t::MusicBrainz::Server::Data::Language;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Language;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $language_data = MusicBrainz::Server::Data::Language->new(c => $test->c);

my $language = $language_data->get_by_id(145);
is ( $language->id, 145 );
is ( $language->iso_code_3, 'deu' );
is ( $language->iso_code_2t, 'deu' );
is ( $language->iso_code_2b, 'ger' );
is ( $language->iso_code_1, 'de' );
is ( $language->name, 'German' );

my $languages = $language_data->get_by_ids(145);
is ( $languages->{145}->id, 145 );
is ( $languages->{145}->iso_code_3, 'deu' );
is ( $languages->{145}->iso_code_2t, 'deu' );
is ( $languages->{145}->iso_code_2b, 'ger' );
is ( $languages->{145}->iso_code_1, 'de' );
is ( $languages->{145}->name, 'German' );

my %languages = $language_data->find_by_codes('de', 'deu', 'ger', 'en', 'es');
is ( $languages{de}->name, 'German', 'German language is loaded for code de' );
is ( $languages{deu}->name, 'German', 'German language is loaded for code deu' );
is ( $languages{ger}->name, 'German', 'German language is loaded for code ger' );
is ( $languages{en}->name, 'English', 'English language is loaded for code en' );
is ( $languages{es}->name, 'Spanish', 'Spanish language is loaded for code es' );

does_ok($language_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @languages = $language_data->get_all;
is(@languages, 13);
is($languages[0]->id, 27);

};

1;
