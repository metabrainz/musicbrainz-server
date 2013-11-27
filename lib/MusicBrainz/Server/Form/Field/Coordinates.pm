package MusicBrainz::Server::Form::Field::Coordinates;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use List::Util qw( first );
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
sub reverse_direction {
    my ($number, $is_latitude) = @_;
    my @dirs;
    if ($is_latitude) {
        @dirs = qw( n s );
    } else {
        @dirs = qw( e w );
    }
    my $direction = first { ($number > 0) eq ($DIRECTIONS{lc $_} > 0) } @dirs;
    return $number * $DIRECTIONS{$direction} . uc $direction
}

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
    my $number_part = q{\d+(?:[\.,]\d+|)};

    $coordinates =~ tr/　．０-９/ .0-9/; # replace fullwidth characters with normal ASCII
    $coordinates =~ s/(北|南)緯\s*(${number_part})度\s*(${number_part})分\s*(${number_part})秒${separators}(東|西)経\s*(${number_part})度\s*(${number_part})分\s*(${number_part})秒/$2° $3' $4" $1, $6° $7' $8" $5/;
    $coordinates =~ tr/北南東西/NSEW/; # replace CJK direction characters

    my $degree_markers = q{°d};
    my $minute_markers = q{′'};
    my $second_markers = q{"″};

    my $decimalPart = '([+\-]?'.$number_part.')\s?['. $degree_markers .']?\s?([NSEW]?)';
    if ($coordinates =~ /^${decimalPart}${separators}${decimalPart}$/i) {
        my ($lat, $long) = swap($2, $4, degree($1, $2), degree($3, $4));
        $self->value({
            latitude => $lat,
            longitude => $long
        });
        return;
    }

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
    $degrees =~ s/,/./;
    $minutes =~ s/,/./;
    $seconds =~ s/,/./;

    return sprintf("%.6f", ((0+$degrees) + ((0+$minutes) * 60 + (0+$seconds)) / 3600) * direction($dir));
}

sub deflate_coordinates {
    my ($self, $value) = @_;
    if (defined $value && defined $value->latitude && defined $value->longitude) {
        return join(', ',
                    reverse_direction($value->latitude, 1),
                    reverse_direction($value->longitude, 0));
    }
}

1;
