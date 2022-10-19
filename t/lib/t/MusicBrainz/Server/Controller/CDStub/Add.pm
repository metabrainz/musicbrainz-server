package t::MusicBrainz::Server::Controller::CDStub::Add;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Entity::CDTOC;

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether adding duplicate CDStubs is blocked as intended.

=cut

test 'Trying to add a CD stub where a real disc ID exists redirects' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdtoc');

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc(
        '1 7 171327 150 22179 49905 69318 96240 121186 143398'
    );
    my $discid = $cdtoc->discid;

    $mech->get_ok(
        '/cdstub/add?toc=' . $cdtoc->toc,
        'Tried to fetch the CDStub addition page to add a known disc ID'
    );

    like($mech->uri, qr{/cdtoc/$discid}, 'Was redirected to the /cdtoc page');
};

1;
