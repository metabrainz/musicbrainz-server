package t::MusicBrainz::Server::Entity::Recording;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Recording;

=head1 DESCRIPTION

This test checks whether recording data is stored correctly.

=cut

test 'Recording data is stored properly' => sub {
    my $rec = MusicBrainz::Server::Entity::Recording->new(
        id => 1,
        name => 'Recording 1',
    );

    is ($rec->id, 1, 'The recording id is stored as expected');
    is (
        $rec->name,
        'Recording 1',
        'The recording name is stored as expected',
    );
};

test 'Can store recording pending edits' => sub {
    my $rec = MusicBrainz::Server::Entity::Recording->new();
    $rec->edits_pending(2);
    is(
        $rec->edits_pending,
        2,
        'The number of pending edits is stored as expected',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
