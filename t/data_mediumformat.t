use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::MediumFormat';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $mf_data = MusicBrainz::Server::Data::MediumFormat->new(c => $c);

my $mf = $mf_data->get_by_id(1);
is ( $mf->id, 1 );
is ( $mf->name, "CD" );

$mf = $mf_data->get_by_id(2);
is ( $mf->id, 2 );
is ( $mf->name, "Vinyl" );

my $mfs = $mf_data->get_by_ids(1, 2);
is ( $mfs->{1}->id, 1 );
is ( $mfs->{1}->name, "CD" );

is ( $mfs->{2}->id, 2 );
is ( $mfs->{2}->name, "Vinyl" );
