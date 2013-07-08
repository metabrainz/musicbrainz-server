package t::MusicBrainz::Server::WebService::Serializer::JSON::2::CDStubTOC;
use Test::Routine;
use Test::Fatal;
use Test::More;
use JSON qw( decode_json );

use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::CDStub;
use MusicBrainz::Server::Entity::CDStubTrack;
use MusicBrainz::Server::Entity::CDStubTOC;
use MusicBrainz::Server::WebService::JSONSerializer;

test 'Can serialize CD stubs to JSON' => sub {
    my $serializer = MusicBrainz::Server::WebService::JSONSerializer->new;

    my $cdstub = MusicBrainz::Server::Entity::CDStub->new(
        comment => "CD Stub comment",
        artist => "Artist",
        title => "Title",
        barcode => MusicBrainz::Server::Entity::Barcode->new("7181"),
        tracks => [
            MusicBrainz::Server::Entity::CDStubTrack->new(
                artist => "LambdaCat",
                title => "Ain't No Type System Gonna Hold Me Back",
                length => 34871
            )
        ]
    );

    my $cdstub_toc = MusicBrainz::Server::Entity::CDStubTOC->new(
        cdstub => $cdstub,
        discid => 'i6hucXpnMSIhNF13L6M8Y2odGP4-'
    );

    is_deeply(
        decode_json($serializer->serialize('cdstub', $cdstub_toc)),
        {
            disambiguation => $cdstub->comment,
            artist => $cdstub->artist,
            title => $cdstub->title,
            tracks => [
                map +{
                    artist => $_->artist,
                    title => $_->title,
                    length => $_->length
                }, $cdstub->all_tracks
            ],
            "track-count" => $cdstub->track_count,
            id => $cdstub_toc->discid,
            barcode => $cdstub->barcode
        }
    );
};

1;

