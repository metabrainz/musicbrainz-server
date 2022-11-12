package t::MusicBrainz::Server::Data::LabelType;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::LabelType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {
    my $test = shift;

    my $lt_data = MusicBrainz::Server::Data::LabelType->new(c => $test->c);

    my $lt = $lt_data->get_by_id(3);
    is ($lt->id, 3);
    is ($lt->name, 'Production');

    my $lts = $lt_data->get_by_ids(3);
    is ($lts->{3}->id, 3);
    is ($lts->{3}->name, 'Production');

    does_ok($lt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = $lt_data->get_all;
    is(@types, 9);
    is($types[0]->id, 1);
    is($types[1]->id, 2);
};

1;
