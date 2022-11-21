package t::MusicBrainz::Server::Entity::ReleaseGroup;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Entity::ReleaseGroupType;

=head1 DESCRIPTION

This test checks whether RG data is stored and calculated correctly.

=cut

test 'Empty RG has undefined calculated data' => sub {
    my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new();
    ok(
        !defined $rg->first_release_date,
        'No first release date is defined for empty release group',
    );

    is(
        $rg->type_name,
        undef,
        'Undefined RG type name is calculated when no type explicitly set',
    );
};

test 'RG type data is stored and calculated properly' => sub {
    my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new();
    $rg->primary_type(
        MusicBrainz::Server::Entity::ReleaseGroupType->new(
            id => 1,
            name => 'Album',
        )
    );

    is(
        $rg->type_name,
        'Album',
        'Expected RG type name is calculated after setting a primary type',
    );

    is($rg->primary_type->id, 1, 'The primary type id is stored as expected');

    is(
        $rg->primary_type->name,
        'Album',
        'The primary type name is stored as expected',
    );
};

test 'Can store RG pending edits' => sub {
    my $rg = MusicBrainz::Server::Entity::ReleaseGroup->new();
    $rg->edits_pending(2);
    is(
        $rg->edits_pending,
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
