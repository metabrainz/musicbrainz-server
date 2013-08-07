package t::MusicBrainz::Server::Controller::WS::js::CoverArtUpload;
use Test::More;
use Test::Routine;
use Test::JSON import => [ 'is_valid_json', 'is_json' ];

with 't::Mechanize', 't::Context';

use JSON;
use MusicBrainz::Server::Test ws_test => {
    version => 'js'
};

test 'jpg post fields' => sub {

    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);
    $c->sql->do("INSERT INTO cover_art_archive.image_type (mime_type, suffix) " .
                "VALUES ('image/jpeg', 'jpg');");

    $mech->default_header ("Accept" => "application/json");
    $mech->get_ok('/ws/js/cover-art-upload/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?mime_type=image/jpeg',
                  'cover art upload signature request');

    is_valid_json ($mech->content);

    my $decoded = from_json ($mech->content);

    ok ($decoded->{image_id} > 4250923260, "image_id is a large integer");
    is ($decoded->{formdata}->{'x-archive-meta-collection'}, "coverartarchive");
    is ($decoded->{formdata}->{'x-archive-auto-make-bucket'}, "1");
    is ($decoded->{formdata}->{'x-archive-meta-mediatype'}, "image");
    is ($decoded->{formdata}->{'key'},
        "mbid-0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e-".$decoded->{image_id}.".jpg");
    is ($decoded->{formdata}->{'acl'}, "public-read");
    is ($decoded->{formdata}->{'content-type'}, "image/jpeg");

};

1;


