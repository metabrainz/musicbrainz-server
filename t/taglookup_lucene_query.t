use strict;
use warnings;
use Test::More tests => 20;
use MusicBrainz::Server::LuceneSearch qw(TagLookupQuery);

my ($query, $type);

($query, $type) = TagLookupQuery('prodigy', '', '', '', '');
is( $query, 'artist:(prodigy) (sortname:(prodigy) alias:(prodigy) !artist:(prodigy))' );
is( $type, 'artist' );

($query, $type) = TagLookupQuery('The Prodigy', 'Fat Of The Land', '', '', '');
is( $query, 'Fat Of The Land artist:(The Prodigy)');
is( $type, 'release' );

($query, $type) = TagLookupQuery('The Prodigy', 'Fat Of The Land', 'Funky Shit', '', '');
is( $query, 'Funky Shit release:(Fat Of The Land) artist:(The Prodigy)');
is( $type, 'track' );

($query, $type) = TagLookupQuery('The Prodigy', '', 'Funky Shit', '', '');
is( $query, 'Funky Shit artist:(The Prodigy)');
is( $type, 'track' );

($query, $type) = TagLookupQuery('The Prodigy', '', 'Funky Shit', '4', '');
is( $query, 'Funky Shit artist:(The Prodigy) tnum:4');
is( $type, 'track' );

($query, $type) = TagLookupQuery('The Prodigy', '', 'Funky Shit', '04', '');
is( $query, 'Funky Shit artist:(The Prodigy) tnum:4');
is( $type, 'track' );

($query, $type) = TagLookupQuery('', '', 'Funky Shit', '', '0');
is( $query, 'Funky Shit');
is( $type, 'track' );

($query, $type) = TagLookupQuery('', '', 'Funky Shit', '', '1000');
is( $query, 'Funky Shit qdur:0 qdur:1');
is( $type, 'track' );

($query, $type) = TagLookupQuery('', '', 'Funky Shit', '', '2000');
is( $query, 'Funky Shit qdur:1 qdur:2 qdur:0');
is( $type, 'track' );

($query, $type) = TagLookupQuery('', '', 'The Narcotic Suite: 3 Kilos', '', '0');
is( $query, 'The Narcotic Suite\\: 3 Kilos');
is( $type, 'track' );
