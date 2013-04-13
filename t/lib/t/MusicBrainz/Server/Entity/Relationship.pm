package t::MusicBrainz::Server::Entity::Relationship;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::Link;


test all => sub {

is( MusicBrainz::Server::Entity::Relationship::_join_attrs([]), '' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A']), 'A' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B']), 'A and B' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B', 'C']), 'A, B and C' );
is( MusicBrainz::Server::Entity::Relationship::_join_attrs(['A', 'B', 'C', 'D']), 'A, B, C and D' );

my $link_type = MusicBrainz::Server::Entity::LinkType->new(
    link_phrase => '{instrument:has %|was} {additional:additionally} arranged by',
    reverse_link_phrase => '{additional:additionally} arranged {instrument:% on}',
);

my $rel;

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [],
    ),
);
is( $rel->phrase, 'was arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'additional',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'additional',
                    id => 1
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'was additionally arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'orchestra',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'has orchestra arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'orchestra',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'piano',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'has orchestra and piano arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'orchestra',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'additional',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'additional',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'has orchestra additionally arranged by' );

my $member_link_type = MusicBrainz::Server::Entity::LinkType->new(
    link_phrase => 'is a {founding} member of',
    reverse_link_phrase => 'has {founding} members',
);

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $member_link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'founding',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'founding',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'vocal',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'vocal',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'guitar',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
                    id => $INSTRUMENT_ROOT_ID
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'is a founding member of' );
is( $rel->extra_phrase_attributes, 'vocal and guitar' );

};

1;
