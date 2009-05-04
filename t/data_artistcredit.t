use strict;
use warnings;
use Test::More tests => 10;
use_ok 'MusicBrainz::Server::Data::ArtistCredit';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $artist_credit_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);

my $ac = $artist_credit_data->get_by_id(1);
is ( $ac->id, 1 );
is ( $ac->artist_count, 2 );
is ( $ac->name, "Queen & David Bowie" );
is ( $ac->names->[0]->name, "Queen" );
is ( $ac->names->[0]->artist_id, 3 );
is ( $ac->names->[0]->join_phrase, " & " );
is ( $ac->names->[1]->name, "David Bowie" );
is ( $ac->names->[1]->artist_id, 3 );
is ( $ac->names->[1]->join_phrase, undef );
