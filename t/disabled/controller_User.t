use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'musicbrainz' }
BEGIN { use_ok 'musicbrainz::Controller::User' }

ok( request('/user')->is_success, 'Request should succeed' );


