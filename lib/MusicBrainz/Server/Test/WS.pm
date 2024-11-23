package MusicBrainz::Server::Test::WS;

use strict;
use warnings;

use base 'Exporter';
use HTTP::Status qw( :constants );
use Readonly;
use MusicBrainz::Server::Test ws_test => { version => 2 };
use MusicBrainz::Server::Test ws_test_json => { version => 2 };
use MusicBrainz::Server::Test ws_test_txt => { version => 2 };

our @EXPORT_OK = qw(
    ws2_test_json
    ws2_test_json_forbidden
    ws2_test_json_unauthorized
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_invalid_mbid
    ws2_test_xml_not_found
    ws2_test_xml_unauthorized
    ws2_test_txt
);

Readonly our $FORBIDDEN_JSON_RESPONSE => {
    error => 'You are not authorized to access this resource.',
    help => 'For usage, please see: https://musicbrainz.org/development/mmd',
};

Readonly our $UNAUTHORIZED_JSON_RESPONSE => {
    error => q(Your credentials could not be verified. Either you supplied the wrong credentials (e.g., bad password), or your client doesn't understand how to supply the credentials required.),
    help => 'For usage, please see: https://musicbrainz.org/development/mmd',
};

Readonly our $FORBIDDEN_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>You are not authorized to access this resource.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML

Readonly our $UNAUTHORIZED_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>Your credentials could not be verified. Either you supplied the wrong credentials (e.g., bad password), or your client doesn't understand how to supply the credentials required.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML

Readonly our $NOT_FOUND_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>Not Found</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML

Readonly our $INVALID_MBID_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>Invalid mbid.</text>
  <text>For usage, please see: https://musicbrainz.org/development/mmd</text>
</error>
EOXML

sub ws2_test_json { ws_test_json(@_) }

sub ws2_test_json_forbidden {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_UNAUTHORIZED;
    ws_test_json($msg, $url, $FORBIDDEN_JSON_RESPONSE, $opts);
}

sub ws2_test_json_unauthorized {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_UNAUTHORIZED;
    ws_test_json($msg, $url, $UNAUTHORIZED_JSON_RESPONSE, $opts);
}

sub ws2_test_xml { ws_test(@_) }

sub ws2_test_xml_forbidden {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_UNAUTHORIZED;
    ws_test($msg, $url, $FORBIDDEN_XML_RESPONSE, $opts);
}

sub ws2_test_xml_unauthorized {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_UNAUTHORIZED;
    ws_test($msg, $url, $UNAUTHORIZED_XML_RESPONSE, $opts);
}

sub ws2_test_xml_not_found {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_NOT_FOUND;
    ws_test($msg, $url, $NOT_FOUND_XML_RESPONSE, $opts);
}

sub ws2_test_xml_invalid_mbid {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = HTTP_BAD_REQUEST;
    ws_test($msg, $url, $INVALID_MBID_XML_RESPONSE, $opts);
}

sub ws2_test_txt { ws_test_txt(@_) }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
