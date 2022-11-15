package t::MusicBrainz::Server::Controller::Artist::AnnotationRevision;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether artist annotation revision pages load,
and whether they display the entirety of the annotation.

=cut

test 'Annotation revision pages display full annotation' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+controller_artist',
    );

    $mech->get_ok(
      '/artist/745c079d-374e-4436-9448-da92dedef3ce/annotation/1',
      'Fetched the annotation revision page',
    );
    $mech->content_contains(
      'Test annotation 1',
      'The annotation is displayed',
    );
    $mech->content_contains(
      'More annotation',
      'The full annotation is shown',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
