use strict;
use warnings;
use Test::More tests => 6;
use_ok 'MusicBrainz::Server::Data::ReleaseLabel';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rl_data = MusicBrainz::Server::Data::ReleaseLabel->new(c => $c);

my $rl = $rl_data->get_by_id(1);
is ( $rl->id, 1 );
is ( $rl->release_id, 1 );
is ( $rl->label_id, 1 );
is ( $rl->catalog_number, "ABC-123" );
is ( $rl->position, 0 );
