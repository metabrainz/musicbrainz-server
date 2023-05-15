package t::MusicBrainz::Server::Data::ReleaseStatus;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ReleaseStatus;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

my $lt_data = MusicBrainz::Server::Data::ReleaseStatus->new(c => $test->c);

my $lt = $lt_data->get_by_id(1);
is ( $lt->id, 1 );
is ( $lt->name, 'Official' );

my $lts = $lt_data->get_by_ids(1);
is ( $lts->{1}->id, 1 );
is ( $lts->{1}->name, 'Official' );

does_ok($lt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @status = $lt_data->get_all;
is(@status, 6);
is($status[0]->id, 1);
is($status[1]->id, 2);
is($status[2]->id, 3);
is($status[3]->id, 4);
is($status[4]->id, 5);
is($status[5]->id, 6);

};

1;
