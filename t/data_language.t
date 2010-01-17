use strict;
use warnings;
use Test::More tests => 14;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::Language';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+language');

my $language_data = MusicBrainz::Server::Data::Language->new(c => $c);

my $language = $language_data->get_by_id(1);
is ( $language->id, 1 );
is ( $language->iso_code_3t, "deu" );
is ( $language->iso_code_3b, "ger" );
is ( $language->iso_code_2, "de" );
is ( $language->name, "German" );

my $languages = $language_data->get_by_ids(1);
is ( $languages->{1}->id, 1 );
is ( $languages->{1}->iso_code_3t, "deu" );
is ( $languages->{1}->iso_code_3b, "ger" );
is ( $languages->{1}->iso_code_2, "de" );
is ( $languages->{1}->name, "German" );

does_ok($language_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @languages = $language_data->get_all;
is(@languages, 1);
is($languages[0]->id, 1);
