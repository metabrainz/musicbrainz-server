use strict;
use warnings FATAL => 'all';
use Test::More tests => 3;

use Test::Aggregate::Nested;


subtest 'Login' => sub {
    Test::Aggregate::Nested->new(
    {
        dirs => 't/selenium/login',
        verbose => 1,
    })->run;
};

subtest 'Bugfixes' => sub {
    Test::Aggregate::Nested->new(
    {
        dirs => 't/selenium/bugfixes',
        verbose => 1,
    })->run;
};

subtest 'Release Editor' => sub {
    Test::Aggregate::Nested->new(
    {
        dirs => 't/selenium/release_editor',
        verbose => 1,
    })->run;
};

