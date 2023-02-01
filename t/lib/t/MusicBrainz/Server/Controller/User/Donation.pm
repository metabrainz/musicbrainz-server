package t::MusicBrainz::Server::Controller::User::Donation;
use strict;
use warnings;

use Test::Routine;

use LWP;
use LWP::UserAgent::Mockable;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/account/donation');
$mech->content_contains('You will never be nagged');

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'kuno', password => 'byld' } );

$mech->get('/account/donation');
$mech->content_contains('We have not received a donation from you recently');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
