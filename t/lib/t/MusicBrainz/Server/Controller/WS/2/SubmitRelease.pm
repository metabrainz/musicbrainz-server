package t::MusicBrainz::Server::Controller::WS::2::SubmitRelease;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::XML::SemanticCompare qw( is_xml_same );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );

use MusicBrainz::Server::Test qw( xml_ok xml_post capture_edits );
use MusicBrainz::Server::Test ws_test => {
    version => 2,
};

test all => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;
    $mech->default_header('Accept' => 'application/xml');

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478', 'foo@example.com', now());
        INSERT INTO release_gid_redirect (gid, new_id)
            VALUES ('78ad6e24-dc0a-4c20-8284-db2d44d28fb9', 49161);
        SQL

    my $isrc = 'JPA600102450';
    my $content = _create_request_content(
        'fbe4eb72-0f24-3875-942e-f581589713d4',
        $isrc,
    );

    my $req = xml_post('/ws/2/release?client=test-1.0', $content);
    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    subtest 'Submissions from Jaikoz are rejected (MBS-8542)' => sub {
        $req = xml_post('/ws/2/release?client=Jaikoz-1.23', $content);
        $mech->request($req);
        is($mech->status, HTTP_BAD_REQUEST);
    };

    subtest 'Submissions of alphanumeric barcodes are rejected' => sub {
        $req = xml_post('/ws/2/release?client=test-1.0', $content);
        $mech->request($req);
        is($mech->status, HTTP_BAD_REQUEST);
        is_xml_same($mech->content, <<~"EOXML");
            <?xml version="1.0"?>
            <error>
                <text>$isrc is not a valid barcode</text>
                <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
            </error>
            EOXML
    };

    my $truncated_barcode = '502160306412';
    $content = _create_request_content(
        'fbe4eb72-0f24-3875-942e-f581589713d4',
        $truncated_barcode,
    );

    subtest 'Submissions of invalid GTIN barcodes are rejected' => sub {
        $req = xml_post('/ws/2/release?client=test-1.0', $content);
        $mech->request($req);
        is($mech->status, HTTP_BAD_REQUEST);
        is_xml_same($mech->content, <<~"EOXML");
            <?xml version="1.0"?>
            <error>
                <text>$truncated_barcode is not a valid GTIN (EAN/UPC) barcode</text>
                <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
            </error>
            EOXML
    };

    my $ean13 = '5021603064126';
    $content = _create_request_content(
        'fbe4eb72-0f24-3875-942e-f581589713d4',
        $ean13,
    );

    $req = xml_post('/ws/2/release?client=test-1.0', $content);
    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditBarcodes');
    is_deeply($edit->data, {
        submissions => [
            {
                release => {
                    id => 243064,
                    name => 'For Beginner Piano',
                },
                barcode => $ean13,
                old_barcode => undef,
            },
        ],
        client_version => 'test-1.0',
    });

    $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list />
</metadata>';

    $req = xml_post('/ws/2/release?client=test-1.0', $content);
    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    my $next_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    is($next_edit->id, $edit->id, 'did not submit an edit');

    my $upc_a = '796122009228';
    $content = _create_request_content(
        '78ad6e24-dc0a-4c20-8284-db2d44d28fb9',
        $upc_a,
    );

    $req = xml_post('/ws/2/release', $content);
    $req->header('User-Agent', 'test-ua');
    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    $next_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    my $rel = $c->model('Release')->get_by_gid('0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e');
    isa_ok($next_edit, 'MusicBrainz::Server::Edit::Release::EditBarcodes');
    is_deeply($next_edit->data, {
        submissions => [
            {
                release => {
                    id => $rel->id,
                    name => $rel->name,
                },
                barcode => $upc_a,
                old_barcode => '4942463511227',
            },
        ],
        client_version => 'test-ua',
    });

    $next_edit->accept;

    my @edits = capture_edits {
        $req = xml_post('/ws/2/release?client=test-1.0', $content);
        $mech->request($req);
        is($mech->status, HTTP_OK);
        xml_ok($mech->content);
    } $c;
    is(@edits => 0);
};

sub _create_request_content {
    my ($recording_mbid, $barcode) = @_;
    return <<~"EOXML";
        <?xml version="1.0" encoding="UTF-8"?>
        <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
          <release-list>
            <release id="$recording_mbid">
              <barcode>$barcode</barcode>
            </release>
          </release-list>
        </metadata>
        EOXML
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
