use strict;
use warnings;
use Test::More;
use Test::Moose;

use_ok 'MusicBrainz::Server::Entity::EditorWatchArtist';

my $watch = 'MusicBrainz::Server::Entity::EditorWatchArtist';
has_attribute_ok($watch, $_)
    for qw( artist_id editor_id artist editor );

done_testing;
