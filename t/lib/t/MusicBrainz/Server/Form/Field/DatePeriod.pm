package t::MusicBrainz::Server::Form::Field::DatePeriod;
use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Form::Field::TestForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'period' => (
        type => '+MusicBrainz::Server::Form::Field::DatePeriod'
    );
}

test 'Test DatePeriod role' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::TestForm->new;

    ok($form->process({ 'period.begin_date.year' => 2000, 'period.end_date.year' => 2000 }), 'can use the same year');
    ok($form->process({ 'period.begin_date.year' => 2000, 'period.end_date.year' => 2001 }), 'can use a later year');
    ok(!$form->process({ 'period.begin_date.year' => 2001, 'period.end_date.year' => 2000 }), 'cannot use a year earlier');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.end_date.year' => 2000,
                        'period.end_date.month' => 5
                    }), 'Same YY-MM date');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.end_date.year' => 2000,
                        'period.end_date.month' => 6
                    }), 'Later YY-MM date');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.begin_date.day' => 5,
                        'period.end_date.year' => 2001,
                        'period.end_date.month' => 1
                    }), 'YY-MM -DD vs later YY-MM');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.begin_date.day' => 17,
                        'period.end_date.year' => 2001,
                        'period.end_date.month' => 1,
                        'period.end_date.day' => 19
                    }), 'Later YY-MM-DD date');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.begin_date.day' => 17,
                        'period.end_date.year' => 2000,
                        'period.end_date.month' => 5,
                        'period.end_date.day' => 17
                    }), 'Same YY-MM-DD date');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.begin_date.day' => 12,
                        'period.end_date.year' => '',
                        'period.end_date.month' => '',
                        'period.end_date.day' => '',
                    }), 'Handles stuff with only a begin date');

    ok($form->process({ 'period.begin_date.year' => 2000,
                        'period.begin_date.month' => 5,
                        'period.begin_date.day' => 12,
                        'period.end_date.year' => 2001,
                        'period.end_date.month' => '',
                        'period.end_date.day' => '',
                    }), 'Handles stuff with only 1 partial date');

    # Bad
    ok(!$form->process({ 'period.begin_date.year' => 2005, 'period.end_date.year' => 1981 }), 'Earlier year');

    ok(!$form->process({ 'period.begin_date.year' => 2007,
                         'period.begin_date.month' => 9,
                         'period.end_date.year' => 2001,
                         'period.end_date.month' => 1
                     }), 'Earlier YY-MM (2007-09 to 2001-01)');
    ok(!$form->process({ 'period.begin_date.year' => 1999,
                         'period.begin_date.month' => 3,
                         'period.end_date.year' => 1980,
                         'period.end_date.month' => 7
                     }), 'Earlier YY-MM (1999-03 to 1980-07)');


    ok(!$form->process({ 'period.begin_date.year' => 2000,
                         'period.begin_date.month' => 5,
                         'period.begin_date.day' => 17,
                         'period.end_date.year' => 2000,
                         'period.end_date.month' => 1,
                         'period.end_date.day' => 19
                     }), 'Earlier YY-MM-DD (2000-05-17 to 2000-01-19)');

    ok(!$form->process({ 'period.begin_date.year' => 2000,
                         'period.begin_date.month' => 5,
                         'period.begin_date.day' => 17,
                         'period.end_date.year' => 2000,
                         'period.end_date.month' => 5,
                         'period.end_date.day' => 16
                     }), 'Earlier YY-MM-DD (2000-05-17 to 2000-05-16)');

    ok(!$form->process({ 'period.begin_date.year' => 1991,
                         'period.begin_date.month' => 11,
                         'period.begin_date.day' => 31,
                         'period.end_date.year' => 1991,
                         'period.end_date.month' => 12,
                         'period.end_date.day' => 20
                     }), "Invalid begin date, valid end date");

    ok(!$form->process({ 'period.begin_date.year' => 1991,
                         'period.begin_date.month' => 11,
                         'period.begin_date.day' => 20,
                         'period.end_date.year' => 1991,
                         'period.end_date.month' => 11,
                         'period.end_date.day' => 31
                     }), "Invalid end date, valid begin date");

    ok(!$form->process({ 'period.begin_date.year' => 1991,
                         'period.begin_date.month' => 11,
                         'period.begin_date.day' => 31,
                         'period.end_date.year' => 1991,
                         'period.end_date.month' => 11,
                         'period.end_date.day' => 31
                     }), "Invalid begin and end dates (same date)");

    ok(!$form->process({ 'period.begin_date.year' => 1991,
                         'period.begin_date.month' => 11,
                         'period.begin_date.day' => 31,
                         'period.end_date.year' => 1992,
                         'period.end_date.month' => 02,
                         'period.end_date.day' => 31
                     }), "Invalid begin and end dates (different dates)");
};

1;
