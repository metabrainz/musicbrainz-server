package MusicBrainz::Server::Form::Field::Time;
use HTML::FormHandler::Moose;
use Time::Piece;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_time );

extends 'HTML::FormHandler::Field::Text';

has '+deflate_method' => (
    default => sub { \&format_time }
);

apply ([
    {
        check => sub { is_valid_time(shift) },
        message => l('This is not a valid time.'),
    }
]);

sub format_time {
    my ($self, $value) = @_;
    my $t = Time::Piece->strptime($value, '%H:%M');
    return $t->strftime('%H:%M');
}

1;
