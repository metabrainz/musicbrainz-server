package t::MusicBrainz::Server::Entity::Relationship;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::Link;


test all => sub {

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
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'piano',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'instrument',
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
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttributeType->new(
                name => 'additional',
                root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'additional',
                ),
            ),
        ]
    ),
);
is( $rel->phrase, 'has orchestra additionally arranged by' );

};

1;
