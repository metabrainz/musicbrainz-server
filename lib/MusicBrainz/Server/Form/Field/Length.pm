package MusicBrainz::Server::Form::Field::Length;
use Moose;

use MusicBrainz::Server::Track;

extends 'HTML::FormHandler::Field::Text';

sub deflate {
    my $self = shift;
    return MusicBrainz::Server::Track::FormatTrackLength($self->value);
}

sub validate
{
    my $self = shift;

    my $length = MusicBrainz::Server::Track::UnformatTrackLength($self->value);
    if ($length == -1) {
        $self->add_error('Not a valid time. Must be in the format MM:SS');
        return;
    }

    $self->_set_value($length);
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
