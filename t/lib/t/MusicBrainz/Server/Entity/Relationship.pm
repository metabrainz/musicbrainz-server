package t::MusicBrainz::Server::Entity::Relationship;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Constants qw( :direction $INSTRUMENT_ROOT_ID );
use MusicBrainz::Server::Entity::Relationship;
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Entity::LinkAttribute;
use MusicBrainz::Server::Entity::Link;


test all => sub {

my $link_type = MusicBrainz::Server::Entity::LinkType->new(
    link_phrase => '{instrument:has %|was} {additional:additionally} arranged by',
    reverse_link_phrase => '{additional:additionally} arranged {instrument:% on}',
);

my $rel;

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [],
    ),
);
is( $rel->phrase, 'was arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'additional',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'additional',
                        id => 1,
                    ),
                ),
            ),
        ],
    ),
);
is( $rel->phrase, 'was additionally arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'orchestra',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'instrument',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
        ],
    ),
);
is( $rel->phrase, 'has orchestra arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'orchestra',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'instrument',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'piano',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'instrument',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
        ],
    ),
);
is( $rel->phrase, 'has orchestra and piano arranged by' );

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'orchestra',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'instrument',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'additional',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'additional',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
        ],
    ),
);
is( $rel->phrase, 'has orchestra additionally arranged by' );

my $member_link_type = MusicBrainz::Server::Entity::LinkType->new(
    link_phrase => 'is a {founding} member of',
    reverse_link_phrase => 'has {founding} members',
);

$rel = MusicBrainz::Server::Entity::Relationship->new(
    direction => $DIRECTION_FORWARD,
    link => MusicBrainz::Server::Entity::Link->new(
        type => $member_link_type,
        attributes => [
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'founding',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'founding',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'vocal',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'vocal',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
            MusicBrainz::Server::Entity::LinkAttribute->new(
                type => MusicBrainz::Server::Entity::LinkAttributeType->new(
                    name => 'guitar',
                    root => MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => 'instrument',
                        id => $INSTRUMENT_ROOT_ID,
                    ),
                ),
            ),
        ],
    ),
);
is( $rel->phrase, 'is a founding member of' );
ok( $rel->extra_phrase_attributes eq 'vocal, guitar' || $rel->extra_phrase_attributes eq 'guitar, vocal' );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
