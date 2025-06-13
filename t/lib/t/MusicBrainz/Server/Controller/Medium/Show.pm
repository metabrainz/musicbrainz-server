package t::MusicBrainz::Server::Controller::Medium::Show;
use strict;
use warnings;

use HTTP::Status qw( :constants );
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test 'redirect' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->max_redirect(0);
    $mech->get('/medium/e67d7889-d617-478f-acc2-40012aec59f5', 'fetch track');

    is($mech->response->code, HTTP_SEE_OTHER, 'response is 303 See Other');
    is($mech->response->header('Location'),
        'http://localhost/release/f34c079d-374e-4436-9448-da92dedef3ce/disc/1#disc1');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
