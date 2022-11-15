package t::MusicBrainz::Server::Controller::WS::js::Release;
use strict;
use warnings;

use Test::More;
use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $c = $test->c;
    my $json = JSON->new->utf8;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header('Accept' => 'application/json');

    my $url = '/ws/js/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=recordings+rels';

    $mech->get_ok($url, 'fetching');

    my $data = $json->decode($mech->content);

    is($data->{mediums}->[0]->{position}, 1, 'first disc has position 1');

    my $rels = $data->{mediums}->[0]->{tracks}->[0]->{recording}->{relationships};
    my ($vocal_performance) = grep { $_->{id} == 6751 } @$rels;

    cmp_deeply($vocal_performance, {
        linkTypeID => 149,
        backward => JSON::true,
        ended => JSON::false,
        target => {
            area => undef,
            begin_area_id => undef,
            begin_date => {
                day => 5,
                month => 11,
                year => 1986,
            },
            comment => '',
            editsPending => JSON::false,
            end_area_id => undef,
            end_date => undef,
            ended => JSON::false,
            entityType => 'artist',
            gender_id => undef,
            gid => 'a16d1433-ba89-4f72-a47b-a370add0bb55',
            id => 9496,
            ipi_codes => [],
            isni_codes => [],
            last_updated => ignore,
            name => 'BoA',
            sort_name => 'BoA',
            typeID => 1,
        },
        editsPending => JSON::false,
        end_date => undef,
        begin_date => undef,
        id => 6751,
        verbosePhrase => 'performed guest vocals on',
        attributes => [
            {
                typeID => 194,
                typeName => 'guest',
                type => {
                    gid => 'b3045913-62ac-433e-9211-ac683cdf6b5c',
                },
            }
        ],
        linkOrder => 0,
        entity0_credit => '',
        entity1_credit => '',
        entity0_id => 9496,
        entity1_id => 4525123,
        source_id => 4525123,
        source_type => 'recording',
        target_type => 'artist'
    }, 'BoA performed vocals');

    is_deeply(
        $data->{mediums}->[0]->{tracks}->[1]->{recording}->{relationships},
        [],
        'No relationships on second track'
    );
};

test 'Release group types are serialized (MBS-8212)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header('Accept' => 'application/json');
    $mech->get_ok('/ws/js/release/3b3d130a-87a8-4a47-b9fb-920f2530d134', 'fetching release');

    my $json = JSON->new->utf8;
    my $data = $json->decode($mech->content);

    is($data->{releaseGroup}{typeID}, 1, 'release group primary type is loaded');
    is_deeply($data->{releaseGroup}{secondaryTypeIDs}, [7], 'release group secondary types are loaded');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
