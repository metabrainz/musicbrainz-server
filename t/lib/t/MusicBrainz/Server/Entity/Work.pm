package t::MusicBrainz::Server::Entity::Work;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Entity::WorkType;
use MusicBrainz::Server::Entity::WorkAlias;

=head1 DESCRIPTION

This test checks whether work data is stored and calculated correctly.

=cut

test 'Empty work has undefined calculated data' => sub {
    my $work = MusicBrainz::Server::Entity::Work->new();

    is(
        $work->type_name,
        undef,
        'Undefined work type name is calculated when no type explicitly set',
    );
};

test 'Work type data is stored and calculated properly' => sub {
    my $work = MusicBrainz::Server::Entity::Work->new();
    $work->type(
        MusicBrainz::Server::Entity::WorkType->new(
            id => 1,
            name => 'Composition',
        )
    );

    is(
        $work->type_name,
        'Composition',
        'Expected work type name is returned after setting a type',
    );

    is($work->type->id, 1, 'The type id is stored as expected');

    is(
        $work->type->name,
        'Composition',
        'The type name is stored as expected',
    );
};

test 'Can store work pending edits' => sub {
    my $work = MusicBrainz::Server::Entity::Work->new();
    $work->edits_pending(2);
    is(
        $work->edits_pending,
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
