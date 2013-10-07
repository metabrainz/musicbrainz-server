package MusicBrainz::Server::Form::Field::Coordinates;
use MusicBrainz::Server::Translation qw( l );
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'latitude' => (
    type => '+HTML::FormHandler::Field::Float',
    range_start => -90,
    range_end => 90,
    size => 9,
    precision => 6,
);

has_field 'longitude' => (
    type => '+HTML::FormHandler::Field::Float',
    range_start => -180,
    range_end => 180,
    size => 9,
    precision => 6,
);

sub validate {
    my $self = shift;

    my $latitude = $self->field('latitude')->value;
    my $longitude = $self->field('longitude')->value;

    # valid coordinates need both latitude and longitude
    return $self->field('longitude')->add_error (l("Please provide both latitude and longitude, or neither")) if ($latitude && !$longitude);
    return $self->field('latitude')->add_error (l("Please provide both latitude and longitude, or neither")) if (!$latitude && $longitude);

    return 1;
}

1;
