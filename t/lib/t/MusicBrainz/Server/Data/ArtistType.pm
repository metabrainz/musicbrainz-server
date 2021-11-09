package t::MusicBrainz::Server::Data::ArtistType;
use Test::Routine;
use Test::Moose;
use Test::More;
use List::AllUtils qw( pairwise );

use MusicBrainz::Server::Data::ArtistType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {
    my $test = shift;

    my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $test->c);

    sub verify_name_and_id {
        my ($id, $name, $at) = @_;
        is ( $at->id, $id , "Expected ID $id found");
        is ( $at->name, $name, "Expected name $name found");
    }

    verify_name_and_id(1, 'Person', $at_data->get_by_id(1));
    verify_name_and_id(2, 'Group', $at_data->get_by_id(2));

    my $ats = $at_data->get_by_ids(1, 2);
    verify_name_and_id(1, 'Person', $ats->{1});
    verify_name_and_id(2, 'Group', $ats->{2});

    does_ok($at_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = $at_data->get_all;
    is(@types, 6, 'Expected number of types found');
    pairwise { is($a->id, $b, 'Found artisttype #'.$a->id) } @types, @{[1..6]};
};

1;
