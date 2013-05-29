package t::MusicBrainz::Server::Data::Area;
use Test::Routine;
use Test::Moose;
use Test::More;

with 't::Context';

my $AREA_GID = 'f03dd94f-a936-42eb-bb97-819102487899';
my $INSERT_AREA = <<"EOSQL";
INSERT INTO area (id, gid, name, sort_name)
  VALUES (1, '$AREA_GID', 'Area', 'Area');
EOSQL

for my $test_data (
    [ 'iso_3166_1', 'CO' ],
    [ 'iso_3166_2', 'US-MD' ],
    [ 'iso_3166_3', 'DDDE' ],
) {
    my ($iso, $code) = @$test_data;
    my $method = "get_by_$iso";

    test $method => sub {
        my $test = shift;
        my $c = $test->c;

        $c->sql->do(<<"EOSQL");
$INSERT_AREA
INSERT INTO $iso (area, code) VALUES (1, '$code');
EOSQL

        my $areas = $c->model("Area")->$method($code, 'NA');
        ok(exists $areas->{$code}, "Found an area for $code");
        ok(exists $areas->{NA}, "There is an entry for NA");
        is($areas->{NA}, undef, "No area for NA");
        is($areas->{$code}->gid, $AREA_GID, "Found $code area");
    };
}

1;
