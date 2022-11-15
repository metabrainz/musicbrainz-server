package t::MusicBrainz::Server::Controller::Place::Create;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test 'Area and area containment shown in conjunction with place' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+area_hierarchy');
    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $mech->get_ok('/place/create');
    html_ok($mech->content);
    $mech->submit_form(
        with_fields => {
            'edit-place.name' => 'Somewhere',
            'edit-place.area_id' => 1178,
        }
    );
    ok($mech->success);

    ok($mech->uri =~ qr{/place/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})$}, 'redirected to new place page');
    html_ok($mech->content);
    $mech->content_contains('London', 'mentions area');
    $mech->content_contains('England', 'mentions containing subdivision');
    $mech->content_contains('United Kingdom', 'mentions containing country');

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Place::Create');
    $mech->get_ok('/edit/' . $edit->id, 'fetch the edit page');
    html_ok($mech->content);
    $mech->content_contains('London', 'mentions area');
    $mech->content_contains('England', 'mentions containing subdivision');
    $mech->content_contains('United Kingdom', 'mentions containing country');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
