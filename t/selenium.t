use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::WWW::Selenium::Parser;
use aliased 'File::Find::Rule' => 'Find';
use LWP::UserAgent;
use MusicBrainz::Server::Test;
BEGIN { MusicBrainz::Server::Test->prepare_test_server }
use Test::WWW::Selenium::Catalyst 'MusicBrainz::Server', -no_selenium_server => 1;
use Try::Tiny;

# Selenium Remote Control should be running at the following host:port.
# See http://wiki.musicbrainz.org/User:kuno/Testing for more info.
my $rc_host = 'localhost';
my $rc_port = 4444;

my $selenium = LWP::UserAgent->new->get (
    "http://$rc_host:$rc_port/selenium-server/core/RemoteRunner.html");

if ($selenium->is_success)
{
    my @tests = (
        't/selenium/login/login.html',
        Find->file->name('*.html')->in('t/selenium/bugfixes'),
        Find->file->name('*.html')->in('t/selenium/release_editor'),
    );

    plan tests => scalar(@tests);

    my $c = MusicBrainz::Server::Test->create_test_context();

    $c->sql->begin;
    $c->raw_sql->begin;

    try {
        MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
        MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
        MusicBrainz::Server::Test->prepare_test_database($c, '+../../admin/sql/SetSequences');

        my $selenium_runner = Test::WWW::Selenium::Parser->new(
            test_runner => Test::WWW::Selenium::Catalyst->start({
                port => 3001,
                selenium_host => $rc_host,
                selenium_port => $rc_port,
            })
        );

        $selenium_runner->parse($_)->run for @tests;
    }
    finally {
        $c->sql->rollback;
        $c->raw_sql->rollback;
        die(@_) if @_;
    };
}
else
{
    plan skip_all => "Cannot connect to Selenium RC at http://$rc_host:$rc_port";
}

