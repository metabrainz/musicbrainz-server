use strict;
use warnings;
use Test::More tests => 3;
use MusicBrainz::Server::Translation;

is (MusicBrainz::Server::Translation::_expand('An {apple_fruit}', apple_fruit => 'apple'), 'An apple', 'Simple replacement');
is (MusicBrainz::Server::Translation::_expand('An {apple_fruit|Apple}', apple_fruit => 'http://www.apple.com'), 'An <a href="http://www.apple.com">Apple</a>', 'Replacement with links');
is (MusicBrainz::Server::Translation::_expand('A {apple_fruit|apple}', apple_fruit => 'http://www.apple.com', apple => "pear"), 'A <a href="http://www.apple.com">pear</a>', 'Replacement with link description evaluation');

