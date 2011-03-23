use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::WWW::Selenium::Parser;

use aliased 'File::Find::Rule' => 'Find';

my $selenium_runner = Test::WWW::Selenium::Parser->new(
    host => 'localhost',
    port => 4444,
    browser => '*chrome',
    browser_url => "http://localhost:3000/"
);

my @tests = (
    't/selenium/login/login.html',
    Find->file->name('*.html')
          ->in('t/selenium/bugfixes')
);

plan tests => scalar(@tests);

$selenium_runner->parse($_)->run for @tests;
