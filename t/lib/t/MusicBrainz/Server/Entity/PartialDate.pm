package t::MusicBrainz::Server::Entity::PartialDate;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use aliased 'MusicBrainz::Server::Entity::PartialDate' => 'Date';

=head1 DESCRIPTION

This test checks partial date generation, emptiness, formatting
and comparison.

=cut

test 'Date emptiness' => sub {
    my $date;
    $date = Date->new();
    ok($date->is_empty, 'Unset date is marked as empty');

    $date = Date->new('');
    ok($date->is_empty, 'Creating a date from an empty string creates an empty date');

    $date = Date->new(year => 2009);
    is($date->year, '2009', 'Year is stored correctly');
    ok(!$date->is_empty, 'A date with a year is not empty');

    $date = Date->new(year => 0);
    ok(!$date->is_empty, 'Year 0 does not mean the date is empty');
};

test 'Creating dates from objects' => sub {
    my $date;
    my $partial;

    note(q({'year' => 1476, 'month' => 12}));
    $partial = {'year' => 1476, 'month' => 12};
    $date = Date->new($partial);
    is($date->year, '1476', 'Year is 1476');
    is($date->month, '12', 'Month is 12');
    is($date->day, undef, 'Day is undef');

    note(q({'year' => 1476, 'month' => 12, 'day' => undef}));
    $partial = {'year' => 1476, 'month' => 12, 'day' => undef};
    $date = Date->new($partial);
    is($date->year, '1476', 'Year is 1476');
    is($date->month, '12', 'Month is 12');
    is($date->day, undef, 'Day is undef');

    note(q({'year' => undef, 'month' => undef, 'day' => undef}));
    $partial = {'year' => undef, 'month' => undef, 'day' => undef};
    $date = Date->new($partial);
    is($date->year, undef, 'Year is undef');
    is($date->month, undef, 'Month is undef');
    is($date->day, undef, 'Day is undef');
    ok($date->is_empty, 'Date is marked as empty');
};

test 'Creating dates from date strings' => sub {
    my $date;

    note('1476');
    $date = Date->new('1476');
    is($date->year, '1476', 'Year is 1476');
    is($date->month, undef, 'Month is undef');
    is($date->day, undef, 'Day is undef');

    note('1476-12');
    $date = Date->new('1476-12');
    is($date->year, '1476', 'Year is 1476');
    is($date->month, '12', 'Month is 12');
    is($date->day, undef, 'Day is undef');

    note('1476-12-1');
    $date = Date->new('1476-12-1');
    is($date->year, '1476', 'Year is 1476');
    is($date->month, '12', 'Month is 12');
    is($date->day, '1', 'Day is 1');

    note('1476-12-01');
    $date = Date->new('1476-12-01');
    is($date->year, '1476', 'Year is 1476');
    is($date->month, '12', 'Month is 12');
    is($date->day, '01', 'Day is 01');
};

test 'String formatting for dates' => sub {
    my $date;

    $date = Date->new();
    is($date->format, '', 'Formatted empty date is the empty string');

    $date = Date->new(year => 2009);
    is($date->format, '2009', 'YYYY formatting works');

    $date = Date->new(year => 2009, month => 4);
    is($date->format, '2009-04', 'YYYY-MM formatting works');

    $date = Date->new(year => 2009, month => 4, day => 18);
    is($date->format, '2009-04-18', 'YYYY-MM-DD formatting works');

    $date = Date->new('1476-12-1');
    my $date_with_leading_zero = Date->new('1476-12-01');
    ok(
        $date->format eq $date_with_leading_zero->format,
        'Present or missing leading zero leads to same formatting result',
    );

    $date = Date->new(month => 4, day => 1);
    is (
        $date->format,
        '????-04-01',
        'Formatting works for dates missing a year',
    );

    $date = Date->new(year => 1999, day => 1);
    is (
        $date->format,
        '1999-??-01',
        'Formatting works for dates missing a month',
    );

    $date = Date->new(day => 1);
    is (
        $date->format,
        '????-??-01',
        'Formatting works for dates having just a day',
    );

    $date = Date->new(month => 1);
    is (
        $date->format,
        '????-01',
        'Formatting works for dates having just a month',
    );

    $date = Date->new(year => 0);
    is ($date->format, '0000', 'Year zero formatting works');

    $date = Date->new(year => -1, month => 1, day => 1);
    is ($date->format, '-001-01-01', 'Negative year formatting works');
};

test 'Date comparison' => sub {
    my ($date1, $date2);

    $date1 = Date->new();
    $date2 = Date->new();
    ok(!($date1 < $date2) && !($date2 > $date1), 'Empty dates sort the same');

    $date1 = Date->new(year => 1995);
    $date2 = Date->new(year => 1995);
    ok(
        !($date1 < $date2) && !($date2 > $date1),
        'Given only year, same year sorts the same',
    );

    $date1 = Date->new(year => -1995);
    $date2 = Date->new(year => -1995);
    ok(
        !($date1 < $date2) && !($date2 > $date1),
        'Given only (negative) year, same year sorts the same',
    );

    $date1 = Date->new(year => 2000);
    $date2 = Date->new(year => 2001);
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Given only year, earlier sorts first',
    );

    $date1 = Date->new( year => 2000, month => 1 );
    $date2 = Date->new( year => 2000, month => 5 );
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Given year and month, earlier sorts first',
    );

    $date1 = Date->new( year => 2000, month => 1, day => 1 );
    $date2 = Date->new( year => 2000, month => 1, day => 20 );
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Given two full dates, earlier sorts first',
    );

    $date1 = Date->new( year => 2000, month => 1, day => 1 );
    $date2 = Date->new( year => 2000, month => 1, day => 1 );
    ok(
        !($date1 < $date2) && !($date2 > $date1),
        'Given two full dates, the same date sorts the same',
    );

    $date1 = Date->new('1476-12-1');
    $date2 = Date->new('1476-12-01');
    ok(
        !($date1 < $date2) && !($date2 > $date1),
        'Present or missing leading zero on date creation sorts the same',
    );

    $date1 = Date->new( month => 1, day => 1 );
    $date2 = Date->new( year => 2000, month => 1, day => 1 );
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Date missing year sorts before full date',
    );

    $date1 = Date->new( month => 1, day => 1 );
    $date2 = Date->new( month => 1, day => 1 );
    ok(
        !($date1 < $date2) && !($date2 > $date1),
        'Dates missing year and otherwise equal sort the same',
    );

    $date1 = Date->new( year => 0 );
    $date2 = Date->new( year => 2000 );
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Year 0 sorts before positive years',
    );

    $date1 = Date->new(year => 0);
    $date2 = Date->new(year => -1);
    ok(
        $date1 > $date2 && $date2 < $date1,
        'Year 0 sorts before negative years',
    );

    $date1 = Date->new(year => -1, month => 1);
    $date2 = Date->new(year => -1, month => 2);
    ok(
        $date2 > $date1 && $date1 < $date2,
        'February sorts after January even for negative years',
    );

    $date1 = Date->new(year => 1994, month => 2, day => 29);
    $date2 = Date->new(year => 1994);
    ok(
        $date1 < $date2 && $date2 > $date1,
        'Invalid dates sort before valid ones',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
