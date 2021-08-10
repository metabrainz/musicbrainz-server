package t::MusicBrainz::Server::Data::Script;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Script;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
my $script_data = MusicBrainz::Server::Data::Script->new(c => $test->c);

my $script = $script_data->get_by_id(3);
is ( $script->id, 3 );
is ( $script->iso_code, 'Ugar' );
is ( $script->name, 'Ugaritic' );

my $scripts = $script_data->get_by_ids(3, 28, 666);
is ( $scripts->{3}->id, 3 );
is ( $scripts->{3}->iso_code, 'Ugar' );
is ( $scripts->{3}->name, 'Ugaritic' );
is ( $scripts->{28}->id, 28 );
is ( $scripts->{28}->iso_code, 'Latn' );
is ( $scripts->{28}->name, 'Latin' );
ok(!exists $scripts->{666});

does_ok($script_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @scripts = $script_data->get_all;
is(@scripts, 4);
is_deeply([sort { $a <=> $b } map { $_->id } @scripts], [3, 28, 85, 112]);

};

1;
