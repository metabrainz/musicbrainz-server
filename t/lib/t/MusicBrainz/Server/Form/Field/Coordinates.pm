package t::MusicBrainz::Server::Form::Field::Coordinates;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply num );
use MusicBrainz::Server::Entity::Coordinates;
use URI;

{
    package t::MusicBrainz::Server::Form::Field::Coordinates::TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'test-edit' );

    has_field 'coordinates' => (
        type => '+MusicBrainz::Server::Form::Field::Coordinates'
    );
}

test 'Correct display for undef coordinates' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new(
        init_object => {
            coordinates => undef
        }
    );

    is($form->field('coordinates')->fif, '', 'displays empty string');
};

test 'Correct display for non-empty coordinates' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new(
        init_object => {
            coordinates => MusicBrainz::Server::Entity::Coordinates->new(
                latitude => 48.28239,
                longitude => -37.67383
            )
        }
    );
    my $expected = '48.28239N, 37.67383W';
    is($form->field('coordinates')->fif, $expected, 'displays $expected');
};

test 'Coordinate validation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new;
    ok(!$form->ran_validation, 'new form has not yet been validated');

    my @tests = (
        {
            parse => '-23.399437,-52.090904',
            latitude => -23.399437,
            longitude => -52.090904
        },
        {
            parse => '40:26:46.302N 079:56:55.903W',
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => '40°26′47″N 079°58′36″W',
            latitude => 40.446389,
            longitude => -79.976667
        },
        {
            parse => '40d 26′ 47″ N 079d 58′ 36″ W',
            latitude => 40.446389,
            longitude => -79.976667
        },
        {
            parse => q{40d 26' 47" N 079d 58′ 36″ W},
            latitude => 40.446389,
            longitude => -79.976667
        },
        {
            parse => q{079d 58′ 36″ W 40d 26' 47" N},
            latitude => 40.446389,
            longitude => -79.976667
        },
        {
            parse => '40.446195N 79.948862W',
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => '40.446195, -79.948862',
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => '+40.446195, -79.948862',
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => '0.1275° W, 51.5072° N',
            latitude => 51.5072,
            longitude => -0.1275
        },
        {
            parse => q{+55° 54' 14.49", +8° 31' 51.64"},
            latitude => 55.904025,
            longitude => 8.531011
        },
        {
            parse => q{52°31′N 13°23′E },
            latitude => 52.516667,
            longitude => 13.383333
        },
        {
            parse => q{北緯３５度３９分５９．８１秒　東経１３９度４４分２９．０６秒},
            latitude => 35.666614,
            longitude => 139.741406
        },
        {
            parse => q{北緯43度2分39.22秒 東経141度21分9.77秒},
            latitude => 43.044228,
            longitude => 141.352714
        },
        {
            parse => q{南緯22度54分30秒 西経43度11分47秒},
            latitude => -22.908333,
            longitude => -43.196389
        },
        {
            parse => q{北緯35度39分59.81秒東経139度44分29.06秒},
            latitude => 35.666614,
            longitude => 139.741406
        },
        {
            parse => q{52,48470 13,39223},
            latitude => 52.48470,
            longitude => 13.39223
        },
        {
            parse => q{55,681192, 12,576282},
            latitude => 55.681192,
            longitude => 12.576282
        },
        {
            parse => q{37, -109},
            latitude => 37,
            longitude => -109
        },
        # Test coordinate rounding
        {
            parse => q{-1.0005633069673305, 32.892379760742195},
            latitude => -1.000563,
            longitude => 32.892380
        },
        {
            parse => q{0.00000000001, 0},
            latitude => 0,
            longitude => 0
        },
    );

    for my $testCase (@tests) {
        $form->process({
            'test-edit' => {
                coordinates => $testCase->{parse}
            }
        });

        ok($form->is_valid, "processed without errors for $testCase->{parse}");
        cmp_deeply($form->field('coordinates')->value, {
            latitude => num($testCase->{latitude}),
            longitude => num($testCase->{longitude})
        }, "Parsing $testCase->{parse}");
        ok( $form->field('coordinates')->value->{latitude} !~ /\.[0-9]*0$/ &&
            $form->field('coordinates')->value->{longitude} !~ /\.[0-9]*0$/,
            'coordinates do not have trailing zeroes (MBS-7438)' );
    }
};

test 'Coordinate validation for empty field' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new;
    my @tests = ( '', '    ' );
    for my $test_string (@tests) {
        $form->process({
            'test-edit' => {
                coordinates => $test_string
            }
        });

        ok($form->is_valid, "processed without errors for '$test_string'");
        ok(! defined $form->field('coordinates')->value, 'result is undef');
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
