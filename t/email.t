#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Email';

BEGIN {
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::_RUNNING_TESTS = sub { 1 };
    *DBDefs::WEB_SERVER = sub { "localhost" };
}

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Editor;

my $c = MusicBrainz::Server::Test->create_test_context();
my $email = MusicBrainz::Server::Email->new( c => $c );

my $user1 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 1', email => 'foo@example.com' );
my $user2 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 2', email => 'bar@example.com' );

my $addr = MusicBrainz::Server::Email::_user_address($user1);
is($addr, '"Editor 1" <foo@example.com>');

$email->send_message_to_editor(
    from => $user1,
    to => $user2,
    subject => 'Hey',
    message => 'Hello!'
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
my $e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 1" <Editor 1@users.musicbrainz.org>');
is($e->get_header('Reply-To'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), '"Editor 2" <bar@example.com>');
is($e->get_header('BCC'), undef);
is($e->get_header('Subject'), 'Hey');
compare_body($e->get_body, <<EOS);
MusicBrainz editor 'Editor 1' has sent you the following message:
------------------------------------------------------------------------
Hello!
------------------------------------------------------------------------
If you would like to respond, please visit
http://localhost/user/Editor\%201/contact to send editor
'Editor 1' an e-mail.
EOS

$email->send_message_to_editor(
    from => $user1,
    to => $user2,
    subject => 'Hey',
    message => 'Hello!',
    reveal_address => 1,
    send_to_self => 1,
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 1" <foo@example.com>');
is($e->get_header('To'), '"Editor 2" <bar@example.com>');
is($e->get_header('BCC'), '"Editor 1" <foo@example.com>');
is($e->get_header('Subject'), 'Hey');
compare_body($e->get_body, <<EOS);
MusicBrainz editor 'Editor 1' has sent you the following message:
------------------------------------------------------------------------
Hello!
------------------------------------------------------------------------
If you would like to respond, please reply to this message or visit
http://localhost/user/Editor\%201/contact to send editor
'Editor 1' an e-mail.
EOS

done_testing;

sub compare_body
{
    my ($got, $expected) = @_;

    $got =~ s/[\r\n]+/\n/g;
    $expected =~ s/[\r\n]+/\n/g;
    is($got, $expected);
}
