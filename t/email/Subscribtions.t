use strict;
use warnings;
use Test::LongString;
use Test::More;
use utf8;

use DBDefs;
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Email::Subscriptions' => 'Email';

my $editor = Editor->new(
    name => 'ニッキー',
    email => 'somebody@example.com'
);

my $email = Email->new(
    editor => $editor,
);

my $text = $email->text;

my $server = sprintf 'http://%s', DBDefs::WEB_SERVER_USED_IN_EMAIL;
my $expected = "$server/user/%E3%83%8B%E3%83%83%E3%82%AD%E3%83%BC/subscriptions";
contains_string($text, $expected, 'Correctly escaped editor name');

done_testing;
