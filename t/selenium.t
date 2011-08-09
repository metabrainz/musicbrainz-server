use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::WWW::Selenium::Parser;
use MusicBrainz::Server::Test qw( commandline_override );
BEGIN { MusicBrainz::Server::Test->prepare_test_server }
use Test::WWW::Selenium::Catalyst 'MusicBrainz::Server', -no_selenium_server => 1;

use aliased 'File::Find::Rule' => 'Find';
use Getopt::Long;
use LWP::UserAgent;
use Try::Tiny;

#
# usage:  prove -l -v t/selenium.t :: [OPTIONS]
#
# options:
#
#    --tests     Specify test files relative to t/selenium/
#    --speed     Execution speed (delay in milliseconds between each step, default is 0)
#
# selenium.t will allways run login/login.html first, even if you specify a list of
# tests to run. A running SeleniumRC server is required, how we run this stuff for
# MusicBrainz is documented at http://wiki.musicbrainz.org/User:kuno/Testing .
#
# example:
#
#    prove -l -v t/selenium.t :: --speed 1000 --tests release_editor/edit-recording.html
#

my $rc_host = 'localhost';
my $rc_port = 4444;

my $selenium = LWP::UserAgent->new->get (
    "http://$rc_host:$rc_port/selenium-server/core/RemoteRunner.html");

if ($selenium->is_success)
{
    my $speed = 0;
    Getopt::Long::Configure ("pass_through");
    GetOptions ("speed=s" => \$speed);

    my @tests = (
        Find->file->name('*.html')->in('t/selenium/bugfixes'),
        Find->file->name('*.html')->in('t/selenium/release_editor'),
    );

    @tests = commandline_override ("t/selenium/", @tests);

    unshift @tests, 't/selenium/login/login.html';

    plan tests => scalar(@tests);

    my $c = MusicBrainz::Server::Test->create_test_context();

    $c->sql->begin;

    try {
        MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
        MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
        MusicBrainz::Server::Test->prepare_test_database($c, '+../../admin/sql/SetSequences');

        my $selenium_runner = Test::WWW::Selenium::Parser->new(
            speed => $speed,
            test_runner => Test::WWW::Selenium::Catalyst->start({
                port => 3001,
                selenium_host => $rc_host,
                selenium_port => $rc_port,
            })
        );

        $selenium_runner->parse($_)->run for @tests;
    }
    catch {
        warn "error: $_";
    }
    finally {
        $c->sql->rollback;
        die(@_) if @_;
    };
}
else
{
    plan skip_all => "Cannot connect to Selenium RC at http://$rc_host:$rc_port";
}

