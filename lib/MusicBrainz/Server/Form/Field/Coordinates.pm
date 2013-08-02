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

=begin comment

This is kind of hacky. If the user doesn't enter any data, the form will
submit with:

    latitude => ''
    longitude => ''

However, in this case we really need:

    latitude => undef,
    longitude => undef

=cut

around '_set_value' => sub
{
    my $orig = shift;
    my ($self, $value) = @_;

    $self->$orig({
        map {
            $_ => !defined $value->{$_} || $value->{$_} eq ''
                ? undef : $value->{$_}
        } keys %$value
    });
};


1;
