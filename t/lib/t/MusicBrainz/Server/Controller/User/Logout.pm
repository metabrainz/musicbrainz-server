package t::MusicBrainz::Server::Controller::User::Logout;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/logout?returnto=/');
html_ok($mech->content);
is($mech->uri->path, '/', 'Redirected to /');
$mech->get_ok('/artist/create');
html_ok($mech->content);
$mech->content_contains('You need to be logged in to view this page');
$mech->get_ok('/logout?returnto=/login');
html_ok($mech->content);
is($mech->uri->path, '/login', 'Redirected to /login');
$mech->content_contains('Log In');

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
