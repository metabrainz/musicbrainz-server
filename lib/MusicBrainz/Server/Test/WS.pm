package MusicBrainz::Server::Test::WS;

use strict;
use warnings;

use base 'Exporter';
use Readonly;
use MusicBrainz::Server::Test ws_test => { version => 2 };

our @EXPORT_OK = qw(
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_unauthorized
);

Readonly our $FORBIDDEN_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>You are not authorized to access this resource.</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>
EOXML

Readonly our $UNAUTHORIZED_XML_RESPONSE => <<'EOXML';
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <text>Your credentials could not be verified. Either you supplied the wrong credentials (e.g., bad password), or your client doesn't understand how to supply the credentials required.</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>
EOXML

sub ws2_test_xml { ws_test(@_) }

sub ws2_test_xml_forbidden {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = 401;
    ws_test($msg, $url, $FORBIDDEN_XML_RESPONSE, $opts);
}

sub ws2_test_xml_unauthorized {
    my ($msg, $url, $opts) = @_;

    $opts //= {};
    $opts->{response_code} = 401;
    ws_test($msg, $url, $UNAUTHORIZED_XML_RESPONSE, $opts);
}
