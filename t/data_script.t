use strict;
use warnings;
use Test::More tests => 10;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::Script';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $script_data = MusicBrainz::Server::Data::Script->new(c => $c);

my $script = $script_data->get_by_id(1);
is ( $script->id, 1 );
is ( $script->iso_code, "Ugar" );
is ( $script->name, "Ugaritic" );

my $scripts = $script_data->get_by_ids(1, 2);
is ( $scripts->{1}->id, 1 );
is ( $scripts->{1}->iso_code, "Ugar" );
is ( $scripts->{1}->name, "Ugaritic" );

does_ok($script_data, 'MusicBrainz::Server::Data::SelectAll');
my @scripts = $script_data->get_all;
is(@scripts, 1);
is($scripts[0]->id, 1);
