package t::MusicBrainz::Server::Form::Field::Coordinates;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_deeply num );
use MusicBrainz::Server::Entity::Coordinates;
use URI;
use utf8;

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

    is ($form->field('coordinates')->fif, '');
};

test 'Correct display for empty coordinates' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new(
        init_object => {
            coordinates => MusicBrainz::Server::Entity::Coordinates->new(
                latitude => undef,
                longitude => undef
            )
        }
    );

    is ($form->field('coordinates')->fif, '');
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

    is ($form->field('coordinates')->fif, '48.28239, -37.67383');
};

test 'Coordinate validation' => sub {
    my $form = t::MusicBrainz::Server::Form::Field::Coordinates::TestForm->new;
    ok(!$form->ran_validation, 'new form has not yet been validated');

    my @tests = (
        {
            parse => "-23.399437,-52.090904",
            latitude => -23.399437,
            longitude => -52.090904
        },
        {
            parse => "40:26:46.302N 079:56:55.903W",
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => "40°26′47″N 079°58′36″W",
            latitude => 40.446389,
            longitude => -79.97667
        },
        {
            parse => "40d 26′ 47″ N 079d 58′ 36″ W",
            latitude => 40.446389,
            longitude => -79.97667
        },
        {
            parse => q{40d 26' 47" N 079d 58′ 36″ W},
            latitude => 40.446389,
            longitude => -79.97667
        },
        {
            parse => q{079d 58′ 36″ W 40d 26' 47" N},
            latitude => 40.446389,
            longitude => -79.97667
        },
        {
            parse => "40.446195N 79.948862W",
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => "40.446195, -79.948862",
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => "+40.446195, -79.948862",
            latitude => 40.446195,
            longitude => -79.948862
        },
        {
            parse => "0.1275° W, 51.5072° N",
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
            parse => q{},
            latitude => undef,
            longitude => undef
        }
    );

    for my $testCase (@tests) {
        $form->process({
            'test-edit' => {
                coordinates => $testCase->{parse}
            }
        });

        ok($form->is_valid, "processed without errors for $testCase->{parse}");
        cmp_deeply($form->field('coordinates')->value, {
            latitude => num($testCase->{latitude}, 0.0001),
            longitude => num($testCase->{longitude}, 0.0001)
        }, "Parsing $testCase->{parse}");
    }
};

1;
