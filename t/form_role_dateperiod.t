use strict;
use warnings;
use Test::More;

{
    package TestForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MusicBrainz::Server::Form::Role::DatePeriod';
}

my $form = TestForm->new;

ok($form->process({ 'begin_date.year' => 2000, 'end_date.year' => 2000 }), 'can use the same year');
ok($form->process({ 'begin_date.year' => 2000, 'end_date.year' => 2001 }), 'can use a later year');
ok(!$form->process({ 'begin_date.year' => 2001, 'end_date.year' => 2000 }), 'cannot use a year earlier');

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'end_date.year' => 2000,
                    'end_date.month' => 5
                }));

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'end_date.year' => 2000,
                    'end_date.month' => 6
                }));

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'begin_date.day' => 5,
                    'end_date.year' => 2001,
                    'end_date.month' => 1
                }));

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'begin_date.day' => 17,
                    'end_date.year' => 2001,
                    'end_date.month' => 1,
                    'end_date.day' => 19
                }));

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'begin_date.day' => 17,
                    'end_date.year' => 2000,
                    'end_date.month' => 5,
                    'end_date.day' => 17
                }));

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'begin_date.day' => 12,
                    'end_date.year' => '',
                    'end_date.month' => '',
                    'end_date.day' => '',
                }), 'Handles stuff with only a begin date');

ok($form->process({ 'begin_date.year' => 2000,
                    'begin_date.month' => 5,
                    'begin_date.day' => 12,
                    'end_date.year' => 2001,
                    'end_date.month' => '',
                    'end_date.day' => '',
                }), 'Handles stuff with only 1 partial date');

# Bad
ok(!$form->process({ 'begin_date.year' => 2005, 'end_date.year' => 1981 }));

ok(!$form->process({ 'begin_date.year' => 2007,
                     'begin_date.month' => 9,
                     'end_date.year' => 2001,
                     'end_date.month' => 1
                 }));
ok(!$form->process({ 'begin_date.year' => 1999,
                     'begin_date.month' => 3,
                     'end_date.year' => 1980,
                     'end_date.month' => 7
                 }));


ok(!$form->process({ 'begin_date.year' => 2000,
                     'begin_date.month' => 5,
                     'begin_date.day' => 17,
                     'end_date.year' => 2000,
                     'end_date.month' => 1,
                     'end_date.day' => 19
                 }));


ok(!$form->process({ 'begin_date.year' => 2000,
                     'begin_date.month' => 5,
                     'begin_date.day' => 17,
                     'end_date.year' => 2000,
                     'end_date.month' => 5,
                     'end_date.day' => 16
                 }));

done_testing;
