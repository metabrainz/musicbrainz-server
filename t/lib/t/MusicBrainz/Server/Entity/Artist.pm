package t::MusicBrainz::Server::Entity::Artist;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use Hook::LexWrap;
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Entity::ArtistType;
use MusicBrainz::Server::Entity::ArtistAlias;

use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $VARTIST_GID );

=head1 DESCRIPTION

This test checks whether artist data is stored and calculated correctly.

=cut

test 'Empty artist has the expected calculated data' => sub {
    my $artist = MusicBrainz::Server::Entity::Artist->new();
    ok(defined $artist->begin_date, 'An empty artist still has a begin date');
    ok($artist->begin_date->is_empty, 'The begin date is empty');
    ok(defined $artist->end_date, 'An empty artist still has an end date');
    ok($artist->end_date->is_empty, 'The end date is empty');

    is(
        $artist->type_name,
        undef,
        'Undefined artist type name is calculated when no type explicitly set',
    );
    is(
        $artist->last_updated,
        undef,
        'last_updated is undefined before any updates have happened',
    );
};

test 'Artist type data is stored and returned properly' => sub {
    my $artist = MusicBrainz::Server::Entity::Artist->new();
    $artist->type(
        MusicBrainz::Server::Entity::ArtistType->new(
            id => 1,
            name => 'Person',
        )
    );
    is(
        $artist->type_name,
        'Person',
        'Expected artist type name is returned after setting a type',
    );
    is($artist->type->id, 1, 'The type id is stored as expected');
    is(
        $artist->type->name,
        'Person',
        'The type name is stored as expected',
    );
};

test 'Can store artist pending edits' => sub {
    my $artist = MusicBrainz::Server::Entity::Artist->new();
    $artist->edits_pending(2);
    is(
        $artist->edits_pending,
        2,
        'The number of pending edits is stored as expected',
    );
};

test 'The right artists (and only them) are marked as special purpose' => sub {
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $DARTIST_ID )->is_special_purpose,
        'An artist with the row id reserved for "Deleted Artist" is marked as special purpose',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( id => $VARTIST_ID )->is_special_purpose,
        'An artist with the row id of "Various Artists" is marked as special purpose',
    );
    ok(
        MusicBrainz::Server::Entity::Artist->new( gid => $VARTIST_GID )->is_special_purpose,
        'An artist with the MBID of "Various Artists" is marked as special purpose',
    );
    ok(
        !MusicBrainz::Server::Entity::Artist->new( id => 5 )->is_special_purpose,
        'An artist with a bog-standard row id is not marked as special purpose',
    );
    ok(
        !MusicBrainz::Server::Entity::Artist->new( gid => '7527f6c2-d762-4b88-b5e2-9244f1e34c46' )->is_special_purpose,
        'An artist with a bog-standard MBID is not marked as special purpose',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
