use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'musicbrainz' }
BEGIN { use_ok 'musicbrainz::Controller::Main' }

ok( request('/main')->is_success, 'Request should succeed' );


