package MusicBrainz::Server::Form::Field::Coordinates;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use utf8;

extends 'MusicBrainz::Server::Form::Field::Text';

has '+deflate_method' => (
    default => sub { \&deflate_coordinates }
);

has '+validate_when_empty' => (
    default => 1
);

my %DIRECTIONS = ( n => 1, s => -1, e => 1, w => -1 );
sub direction { $DIRECTIONS{lc (shift() // '')} // 1}

sub swap {
    my ($direction_lat, $direction_long, $lat, $long) = @_;

    $direction_lat //= 'n';
    $direction_long //= 'e';

    # We expect lat/long, but can support long/lat
    if (lc $direction_lat eq 'e' || lc $direction_lat eq 'w' ||
        lc $direction_long eq 'n' || lc $direction_long eq 's') {
        return ($long, $lat);
    }
    else {
        return ($lat, $long);
    }
}

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    my $coordinates = $self->value;

    if ($coordinates =~ /^\s*$/) {
        $self->value({ latitude => undef, longitude => undef });
        return;
    }

    my $separators = '\s?,?\s?';
    my $degree_markers = q{°d};
    my $minute_markers = q{′'};
    my $second_markers = q{"″};
    my $number_part = q{\d+(?:\.\d+|)};

    my $decimalPart = '([+\-]?'.$number_part.')\s?['. $degree_markers .']?\s?([NSEW]?)';
    if ($coordinates =~ /^${decimalPart}${separators}${decimalPart}$/i) {
        my ($lat, $long) = swap($2, $4, degree($1, $2), degree($3, $4));
        $self->value({
            latitude => $lat,
            longitude => $long
        });
        return;
    }

    my $dmsPart = '(?:([+\-]?\d+)[:°d]\s?(\d+)[:′\']\s?(\d+(?:\.\d+|)))["″]?\s?([NSEW]?)';
    my $dmsPart = '(?:([+\-]?'.$number_part.')[:'.$degree_markers.']\s?' .
                  '('.$number_part.')[:'.$minute_markers.']\s?' .
                  '(?:('.$number_part.')['.$second_markers.']?)?\s?([NSEW]?))';
    if ($coordinates =~ /^${dmsPart}${separators}${dmsPart}$/i) {
        my ($lat, $long) = swap($4, $8, dms($1, $2, $3 // 0, $4), dms($5, $6, $7 // 0, $8));

        $self->value({
            latitude  => $lat,
            longitude => $long
        });
        return;
    }

    return $self->add_error(l('These coordinates could not be parsed'));
}

sub degree {
    my ($degrees, $dir) = @_;
    return dms($degrees, 0, 0, $dir);
}

sub dms {
    my ($degrees, $minutes, $seconds, $dir) = @_;
    return sprintf("%.6f", ((0+$degrees) + ((0+$minutes) * 60 + (0+$seconds)) / 3600) * direction($dir));
}

sub deflate_coordinates {
    my ($self, $value) = @_;
    if (defined $value && defined $value->latitude && defined $value->longitude) {
        return join(', ', $value->latitude, $value->longitude);
    }
}

1;
