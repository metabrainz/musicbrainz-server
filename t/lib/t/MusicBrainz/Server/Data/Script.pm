package t::MusicBrainz::Server::Data::Script;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::Script';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

test all => sub {

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+script');

my $script_data = MusicBrainz::Server::Data::Script->new(c => $c);

my $script = $script_data->get_by_id(1);
is ( $script->id, 1 );
is ( $script->iso_code, "Ugar" );
is ( $script->name, "Ugaritic" );

my $scripts = $script_data->get_by_ids(1, 2);
is ( $scripts->{1}->id, 1 );
is ( $scripts->{1}->iso_code, "Ugar" );
is ( $scripts->{1}->name, "Ugaritic" );

does_ok($script_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @scripts = $script_data->get_all;
is(@scripts, 1);
is($scripts[0]->id, 1);


};

1;
