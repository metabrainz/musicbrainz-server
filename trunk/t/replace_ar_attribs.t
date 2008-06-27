use strict;
use warnings;
use Test::More tests => 14;
use MusicBrainz::Server::Attribute;

is( MusicBrainz::Server::Attribute::_replace_attributes(
	'was composed by', {}),
	'was composed by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'was {additional} composed by', {}),
	'was composed by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'was {additional} composed by', {'additional' => ['additional']}),
	'was additional composed by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'was {additional:additionally} composed by', {'additional' => ['additional']}),
	'was additionally composed by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'was {additional:additionally|not additionally} composed by', {}),
	'was not additionally composed by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'{instrument:has %|was} {additional:additionally} arranged by', {}),
	'was arranged by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'{instrument:has %|was} {additional:additionally} arranged by', {'instrument' => ['piano']}),
	'has piano arranged by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'{instrument:has %|was} {additional:additionally} arranged by', {'instrument' => ['piano'], 'additional' => ['additional']}),
	'has piano additionally arranged by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'{instrument:has %|was} {additional:additionally} arranged by', {'additional' => ['additional']}),
	'was additionally arranged by' );
is( MusicBrainz::Server::Attribute::_replace_attributes(
	'{instrument+vocal:has %|was} {additional:additionally} arranged by', {'instrument' => ['piano'], 'vocal' => ['vocal']}),
	'has piano and vocal arranged by' );

is( MusicBrainz::Server::Attribute::_join_words(['a']), 'a' );
is( MusicBrainz::Server::Attribute::_join_words(['a', 'b']), 'a and b' );
is( MusicBrainz::Server::Attribute::_join_words(['a', 'b', 'c']), 'a, b and c' );
is( MusicBrainz::Server::Attribute::_join_words(['a', 'b', 'c', 'd']), 'a, b, c and d' );
