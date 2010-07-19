use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

BEGIN {
    $ENV{ LWP_UA_MOCK } ||= 'playback';
    $ENV{ LWP_UA_MOCK_FILE } ||= $Bin.'/donation.metabrainz-nagcheck.lwp-mock';
}

use LWP;
use LWP::UserAgent::Mockable;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/user/kuno/donation');
is ($mech->status(), 403, "Donations are private");

$mech->get('/user/new_editor/donation');
$mech->content_contains ("You will never be nagged");


$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'kuno', password => 'byld' } );

$mech->get('/user/kuno/donation');
$mech->content_contains ("We have not received a donation from you recently");

LWP::UserAgent::Mockable->finished;

done_testing;

1;
