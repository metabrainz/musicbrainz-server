package t::MusicBrainz::Server::Form::Area;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Form::Area;

my $AREA_GID = 'f03dd94f-a936-42eb-bb97-819102487899';

with 't::Context';

for my $config (
    [ 'iso_3166_1', 'CO' ],
    [ 'iso_3166_2', 'US-MD' ],
    [ 'iso_3166_3', 'DDDE' ],
) {
    my ($iso_field, $iso_code) = @$config;

    test "Cannot submit duplicate ISO codes ($iso_field)" => sub {
        my $test = shift;
        my $c = $test->c;

        prepare_conflict($c, $iso_field, $iso_code);

        my $form = MusicBrainz::Server::Form::Area->new(ctx => form_context($c));
        ok(
            !$form->process(
                params => {
                    'edit-area.name' => 'Area',
                    'edit-area.sort_name' => 'Area',
                    "edit-area.$iso_field.0" => $iso_code
                }
            ),
            'form did not validate'
        );
    };

    test "Editing own area does not violate ISO uniqueness ($iso_field)" => sub
    {
        my $test = shift;
        my $c = $test->c;

        prepare_conflict($c, $iso_field, $iso_code);

        my $form = MusicBrainz::Server::Form::Area->new(
            ctx => form_context($c),
            init_object => $c->model('Area')->get_by_id(1)
        );
        ok(
            $form->process(
                params => {
                    'edit-area.name' => 'Renamed',
                    'edit-area.sort_name' => 'Renamed',
                    "edit-area.$iso_field.0" => $iso_code
                }
            ),
            'form submitted sucessfully'
        );
    };
}

sub prepare_conflict {
    my ($c, $iso_field, $iso_code) = @_;

    $c->sql->do(<<"EOSQL");
INSERT INTO area (id, gid, name, sort_name)
  VALUES (1, '$AREA_GID', 'Area', 'Area');
INSERT INTO $iso_field (area, code) VALUES (1, '$iso_code');
EOSQL
}

sub form_context {
    my $c = shift;
    return t::FormContext->meta->rebless_instance($c);
}

package t::FormContext;
use Moose;
use Unicode::ICU::Collator qw( UCOL_NUMERIC_COLLATION UCOL_ON );
use MusicBrainz::Server::Translation;
extends 'MusicBrainz::Server::Context';

has user => (
    is => 'ro',
    default => sub {
        MusicBrainz::Server::Entity::Editor->new(
            privileges => 0
        )
    }
);

has stash => (
    is => 'ro',
    default => sub { +{} }
);

sub get_collator { MusicBrainz::Server::Translation::get_collator('en') }

1;
