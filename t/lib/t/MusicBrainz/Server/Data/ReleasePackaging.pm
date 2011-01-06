package t::MusicBrainz::Server::Data::ReleasePackaging;
use Test::Routine;
use Test::Moose;
use Test::More;

use_ok 'MusicBrainz::Server::Data::ReleasePackaging';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

test all => sub {

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+releasepackaging');

my $lt_data = MusicBrainz::Server::Data::ReleasePackaging->new(c => $c);

my $lt = $lt_data->get_by_id(1);
is ( $lt->id, 1 );
is ( $lt->name, "Jewel Case" );

my $lts = $lt_data->get_by_ids(1);
is ( $lts->{1}->id, 1 );
is ( $lts->{1}->name, "Jewel Case" );

does_ok($lt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @types = $lt_data->get_all;
is(@types, 1);
is($types[0]->id, 1);

};

1;
