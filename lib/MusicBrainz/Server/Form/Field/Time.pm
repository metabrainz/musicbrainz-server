package MusicBrainz::Server::Form::Field::Time;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_time );

extends 'HTML::FormHandler::Field::Text';

has '+deflate_method' => (
    default => sub { \&format_time }
);

apply ([
    {
        check => sub { is_valid_time(shift) },
        message => sub { l('This is not a valid time.') },
    }
]);

sub format_time {
    my ($self, $value) = @_;
    return $value ? $value->strftime('%H:%M') : undef;
}

1;
