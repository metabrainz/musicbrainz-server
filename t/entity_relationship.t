#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

use_ok 'MusicBrainz::Server::Entity::Relationship';
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::Link;

is( MusicBrainz::Server::Entity::Relationship::_join_attrs([]), '' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A']), 'a' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B']), 'a and b' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B', 'C']), 'a, b and c' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B', 'C', 'D']), 'a, b, c and d' );

my $link_type = MusicBrainz::Server::Entity::LinkType->new(
    link_phrase => '{instrument:has %|was} {additional:additionally} arranged by',
    reverse_link_phrase => '{additional:additionally} arranged {instrument:% on}',
);

my $rel;

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => {},
    ),
);
is( $rel->phrase, 'was arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => {
            'additional' => ['additional'],
        },
    ),
);
is( $rel->phrase, 'was additionally arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => {
            'instrument' => ['orchestra'],
        },
    ),
);
is( $rel->phrase, 'has orchestra arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => {
            'instrument' => ['orchestra', 'piano'],
        },
    ),
);
is( $rel->phrase, 'has orchestra and piano arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => {
            'instrument' => ['orchestra'],
            'additional' => ['additional'],
        },
    ),
);
is( $rel->phrase, 'has orchestra additionally arranged by' );
