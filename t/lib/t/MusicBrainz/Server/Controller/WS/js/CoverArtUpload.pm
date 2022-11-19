package t::MusicBrainz::Server::Controller::WS::js::CoverArtUpload;
use strict;
use warnings;

use Test::More;
use Test::Routine;
use Test::JSON import => [ 'is_json' ];

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

    # Insert a fake piece of cover art for the release so that we don't
    # have to perform a bucket ownership check in
    # /ws/js/cover-art-upload, which requires external HTTP requests.
    $c->sql->do(<<~'SQL');
        INSERT INTO edit (id, editor, type, status, expire_time)
            VALUES (1, 1, 314, 2, '2000-01-01');

        INSERT INTO cover_art_archive.cover_art (id, release, edit, ordering, date_uploaded, mime_type)
            VALUES (1, 2, 1, 1, now(), 'image/jpeg');
        SQL

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->default_header('Accept' => 'application/json');
    $mech->get_ok('/ws/js/cover-art-upload/f205627f-b70a-409d-adbe-66289b614e80?mime_type=image/jpeg',
                  'cover art upload signature request');

    my $decoded = from_json($mech->content);

    ok($decoded->{image_id} > 4250923260, 'image_id is a large integer');
    is($decoded->{formdata}->{'x-archive-meta-collection'}, 'coverartarchive');
    is($decoded->{formdata}->{'x-archive-auto-make-bucket'}, '1');
    is($decoded->{formdata}->{'x-archive-meta-mediatype'}, 'image');
    is($decoded->{formdata}->{'key'},
        'mbid-f205627f-b70a-409d-adbe-66289b614e80-'.$decoded->{image_id}.'.jpg');
    is($decoded->{formdata}->{'acl'}, 'public-read');
    is($decoded->{formdata}->{'content-type'}, 'image/jpeg');
};

1;
