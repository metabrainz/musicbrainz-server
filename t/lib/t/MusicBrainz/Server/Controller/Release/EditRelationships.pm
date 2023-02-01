package t::MusicBrainz::Server::Controller::Release::EditRelationships;
use strict;
use warnings;

use Test::Routine;

with 't::Context', 't::Mechanize';

test 'MBS-5348: Displays version count in "see all versions" string' => sub {
    my $test = shift;
    my ($c, $mech) = ($test->c, $test->mech);

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/release/f34c079d-374e-4436-9448-da92dedef3ce/edit-relationships');
    $mech->content_contains('see all versions of this release, 1 available', '...has 1 available');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
