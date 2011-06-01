use strict;
use warnings;
use Test::LongString;
use Test::More;

use DBDefs;
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Email::Subscriptions' => 'Email';

my $editor = Editor->new(
    name => 'My Name',
    email => 'somebody@example.com'
);

my $email = Email->new(
    editor => $editor,
);

my $text = $email->text;

my $server = sprintf 'http://%s', DBDefs::WEB_SERVER;
my $expected = "$server/user/My%20Name/subscriptions";
contains_string($text, $expected, 'Correctly escaped editor name');

done_testing;
