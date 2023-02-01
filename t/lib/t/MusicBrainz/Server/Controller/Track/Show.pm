package t::MusicBrainz::Server::Controller::Track::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test 'redirect' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->max_redirect(0);
    $mech->get('/track/3fd2523e-1ced-4f83-8b93-c7ecf6960b32', 'fetch track');

    is($mech->response->code, 303, 'response is 303 See Other');
    is($mech->response->header('Location'),
        'http://localhost/release/f34c079d-374e-4436-9448-da92dedef3ce/disc/1#3fd2523e-1ced-4f83-8b93-c7ecf6960b32');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
