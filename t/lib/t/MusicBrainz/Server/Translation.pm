package t::MusicBrainz::Server::Translation;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Translation;

test 'Check _expand_link' => sub {
    is(MusicBrainz::Server::Translation->instance->expand('An {apple_fruit}',
                                                  apple_fruit => 'apple'),
        'An apple', 'Simple replacement');
    is(MusicBrainz::Server::Translation->instance->expand('An {apple_fruit|Apple}',
                                                  apple_fruit => 'http://www.apple.com'),
        'An <a href="http://www.apple.com">Apple</a>', 'Replacement with links');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|apple}',
                                                  apple_fruit => 'http://www.apple.com', apple => 'pear'),
        'A <a href="http://www.apple.com">pear</a>', 'Replacement with link description evaluation');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|apple}',
                                                  apple_fruit => {href => 'http://www.apple.com', target => '_blank'}, apple => 'pear'),
        'A <a href="http://www.apple.com" target="_blank">pear</a>', 'Replacement with link description evaluation and hash argument');
    is(MusicBrainz::Server::Translation->instance->expand('A {apple_fruit|{condition} apple …}',
                                                  apple_fruit => {href => 'http://www.apple.com', target => '_blank'}, condition => 'bad'),
        'A <a href="http://www.apple.com" target="_blank">bad apple …</a>', 'Replacement with link description evaluation and nested hash argument');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
