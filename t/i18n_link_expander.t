use strict;
use warnings;
use Test::More tests => 3;
use Catalyst::Plugin::I18N::Gettext;

is (Catalyst::Plugin::I18N::Gettext::__expand('An {apple_fruit}', apple_fruit => 'apple'), 'An apple', 'Simple replacement');
is (Catalyst::Plugin::I18N::Gettext::__expand('An {apple_fruit|Apple}', apple_fruit => 'http://www.apple.com'), 'An <a href="http://www.apple.com">Apple</a>', 'Replacement with links');
is (Catalyst::Plugin::I18N::Gettext::__expand('A {apple_fruit|apple}', apple_fruit => 'http://www.apple.com', apple => "pear"), 'A <a href="http://www.apple.com">pear</a>', 'Replacement with link description evaluation');

