package t::MusicBrainz::Server::Form::Field::PartialDate;
use strict;
use warnings;

use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Form::Field::PartialDate::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field $_ => (
        type => '+MusicBrainz::Server::Form::Field::PartialDate',
    ) for qw( full_date no_day day_40 no_year leap_year_valid leap_year_invalid
              no_leap_year_valid no_leap_year_invalid );
}

test 'Partial date field validation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::PartialDate::TestForm->new();
    ok(!$form->ran_validation, 'new form, not yet has_errors');

    $form->process({ 'test-edit' => {
        'full_date' => { 'year' => '2008', 'month' => '1', 'day' => '29' },
        'no_day' => { 'year' => '2008', 'month' => '11' },
        'day_40' => { 'year' => '2008', 'month' => '01', 'day' => '40' },
        'no_year' => { 'month' => '11' },
        'leap_year_valid' => { 'year' => '2000', 'month' => '02', 'day' => '29' },
        'leap_year_invalid' => { 'year' => '2000', 'month' => '02', 'day' => '30' },
        'no_leap_year_valid' => { 'year' => '1999', 'month' => '02', 'day' => '28' },
        'no_leap_year_invalid' => { 'year' => '1999', 'month' => '02', 'day' => '29' },
    }});

    ok($form->ran_validation, 'processed form, validation run');
    ok(!$form->is_valid, 'processed form, with invalid fields');

    my $full_date = $form->field('full_date');
    is($full_date->field('year')->value, 2008, 'full date, year is 2008');
    is($full_date->field('month')->value, 1, 'full date, month is january');
    is($full_date->field('day')->value, 29, 'full date, day is 29th');
    ok(!$full_date->has_errors, 'full date is valid');

    my $no_day = $form->field('no_day');
    is($no_day->field('year')->value, 2008, 'no day, year is 2008');
    is($no_day->field('month')->value, 11, 'no day, month is 11');
    is($no_day->field('day')->value, undef, 'no day, day is undef');
    ok(!$no_day->has_errors, 'no day is valid');

    ok($form->field('day_40')->has_errors, 'day 40 is invalid');

    ok(!$form->field('leap_year_valid')->has_errors, 'february 2000 has a day 29');
    ok($form->field('leap_year_invalid')->has_errors, 'february 2000 has no day 30');
    ok(!$form->field('no_leap_year_valid')->has_errors, 'february 1999 has a day 28');
    ok($form->field('no_leap_year_invalid')->has_errors, 'february 1999 has no day 29');

    my $no_year = $form->field('no_year');
    ok(!$no_year->has_errors, 'no_year is valid');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
