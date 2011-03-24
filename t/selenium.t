use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::WWW::Selenium::Parser;

use aliased 'File::Find::Rule' => 'Find';

use LWP::UserAgent;

# Selenium Remote Control should be running at the following host:port.
# See http://wiki.musicbrainz.org/User:kuno/Testing for more info.
my $rc_host = 'localhost';
my $rc_port = 4444;

# my $musicbrainz = LWP::UserAgent->new->get ("http://localhost:3000
my $selenium = LWP::UserAgent->new->get (
    "http://$rc_host:$rc_port/selenium-server/core/RemoteRunner.html");

if ($selenium->is_success)
{
    my $selenium_runner = Test::WWW::Selenium::Parser->new(
        host => $rc_host,
        port => $rc_port,
        browser => '*chrome',
        browser_url => "http://localhost:3000/"
    );

    my @tests = (
        't/selenium/login/login.html',
#         Find->file->name('*.html')->in('t/selenium/bugfixes'),
#         Find->file->name('*.html')->in('t/selenium/release_editor'),
    );

    plan tests => scalar(@tests);

    $selenium_runner->parse($_)->run for @tests;
}
else
{
    plan skip_all => "Cannot connect to Selenium RC at http://$rc_host:$rc_port";
}

