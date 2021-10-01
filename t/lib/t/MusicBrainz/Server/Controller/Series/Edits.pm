package t::MusicBrainz::Server::Controller::Series::Edits;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/edits',
                  'fetch series edit history');
};

1;
