package t::MusicBrainz::Server::Controller::Recording::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/aliases', 'fetch recording aliases');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
        'alternateName' => ['King of the Mt.'],
        'isrcCode' => 'DEE250800230',
        '@type' => 'MusicRecording',
        '@context' => 'http://schema.org',
        'duration' => 'PT04M54S',
        'name' => 'King of the Mountain'
    };
};

1;
