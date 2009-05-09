use strict;
use warnings;
use Test::More tests => 7;
use_ok 'MusicBrainz::Server::Data::Script';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
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
