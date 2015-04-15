package t::MusicBrainz::Server::Controller::WS::js::Release;
use Test::More;
use Test::Deep qw( cmp_deeply any );
use Test::Routine;
use JSON;
use MusicBrainz::Server::Test;
use Test::JSON import => [ 'is_valid_json' ];

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $c = $test->c;
    my $json = JSON::Any->new( utf8 => 1 );

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header("Accept" => "application/json");

    my $url = '/ws/js/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=recordings+rels+media';

    $mech->get_ok($url, 'fetching');
    is_valid_json($mech->content, "validating (is_valid_json)");

    my $data = $json->decode($mech->content);

    is($data->{mediums}->[0]->{position}, 1, "first disc has position 1");

    my $rels = $data->{mediums}->[0]->{tracks}->[0]->{recording}->{relationships};
    my ($vocal_performance) = grep { $_->{id} == 6751 } @$rels;

    cmp_deeply($vocal_performance, {
        linkTypeID => 158,
        direction => 'backward',
        ended => any('false', JSON::false),
        target => {
            comment => '',
            sortName => 'BoA',
            entityType => 'artist',
            name => 'BoA',
            id => 9496,
            gid => 'a16d1433-ba89-4f72-a47b-a370add0bb55'
        },
        editsPending => any('false', JSON::false),
        endDate => undef,
        beginDate => undef,
        id => 6751,
        verbosePhrase => 'vocal',
        attributes => [
            {
                type => {
                    gid => 'b3045913-62ac-433e-9211-ac683cdf6b5c',
                },
            }
        ],
        linkOrder => 0,
    }, "BoA performed vocals");

    is($data->{mediums}->[0]->{tracks}->[1]->{recording}->{relationships},
       undef, "No relationships on second track");
};

test 'Release group types are serialized (MBS-8212)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');
    $mech->default_header("Accept" => "application/json");
    $mech->get_ok('/ws/js/release/3b3d130a-87a8-4a47-b9fb-920f2530d134', 'fetching release');

    my $json = JSON::Any->new(utf8 => 1);
    my $data = $json->decode($mech->content);

    is($data->{releaseGroup}{typeID}, 1, "release group primary type is loaded");
    is_deeply($data->{releaseGroup}{secondaryTypeIDs}, [7], "release group secondary types are loaded");
};

1;
