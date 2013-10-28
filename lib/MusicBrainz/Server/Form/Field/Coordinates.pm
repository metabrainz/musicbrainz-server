package MusicBrainz::Server::Form::Field::Coordinates;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use utf8;

extends 'MusicBrainz::Server::Form::Field::Text';

has '+deflate_method' => (
    default => sub { \&deflate_coordinates }
);

my %DIRECTIONS = ( n => 1, s => -1, e => 1, w => -1 );
sub direction { $DIRECTIONS{lc shift} // 1}

sub validate {
    my $self = shift;

    return unless $self->SUPER::validate;

    my $coordinates = $self->value;

    my $separators = '\s?,?\s?';

    my $decimalPart = '(\-?\d+(?:\.\d+|))([nsew]?)';
    if ($coordinates =~ /^${decimalPart}${separators}${decimalPart}$/i) {
        $self->value({
            latitude => degree($1, $2),
            longitude => degree($3, $4)
        });
        return;
    }

    my $dmsPart = '(?:(\d+)[:°d]\s?(\d+)[:′\']\s?(\d+(?:\.\d+|)))["″]?\s?([NSEW]?)';
    if ($coordinates =~ /^${dmsPart}${separators}${dmsPart}$/i) {
        $self->value({
            latitude  => dms($1, $2, $3, $4),
            longitude => dms($5, $6, $7, $8)
        });
        return;
    }

    return $self->add_error(l('These coordinates could not be parsed'));
}

sub degree {
    my ($degrees, $dir) = @_;
    return sprintf("%.6f", $degrees * direction($dir));
}

sub dms {
    my ($degrees, $minutes, $seconds, $dir) = @_;
    return sprintf("%.6f", ((0+$degrees) + ((0+$minutes) * 60 + (0+$seconds)) / 3600) * direction($dir));
}

sub deflate_coordinates {
    my ($self, $value) = @_;
    return join(', ', $value->latitude, $value->longitude);
}

1;
