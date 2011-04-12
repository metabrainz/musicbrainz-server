package t::MusicBrainz::Server::Data::Script;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use MusicBrainz::Server::Data::Script;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+script');

my $script_data = MusicBrainz::Server::Data::Script->new(c => $test->c);
memory_cycle_ok($script_data);

my $script = $script_data->get_by_id(1);
is ( $script->id, 1 );
is ( $script->iso_code, "Ugar" );
is ( $script->name, "Ugaritic" );
memory_cycle_ok($script_data);
memory_cycle_ok($script);

my $scripts = $script_data->get_by_ids(1, 2);
is ( $scripts->{1}->id, 1 );
is ( $scripts->{1}->iso_code, "Ugar" );
is ( $scripts->{1}->name, "Ugaritic" );

memory_cycle_ok($script_data);
memory_cycle_ok($scripts);

does_ok($script_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @scripts = $script_data->get_all;
is(@scripts, 1);
is($scripts[0]->id, 1);

memory_cycle_ok($script_data);
memory_cycle_ok(\@scripts);

};

1;
