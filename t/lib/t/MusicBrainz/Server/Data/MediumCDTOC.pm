package t::MusicBrainz::Server::Data::MediumCDTOC;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::MediumCDTOC;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context';

test all => sub {
my $test = shift;
my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+medium-cdtoc');

    my @edits = capture_edits {
        $c->model('MediumCDTOC')->insert({medium => 1, cdtoc => 1});
    } $c;

    is(@edits, 1, 'created 1 edit');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::SetTrackLengths', 'is a "Set Track Lengths" edit');
    is($edits[0]->editor_id, 4, 'ModBot is editor');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
