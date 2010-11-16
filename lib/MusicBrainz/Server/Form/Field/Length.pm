package MusicBrainz::Server::Form::Field::Length;
use Moose;

use MusicBrainz::Server::Track;
use MusicBrainz::Server::Translation qw( l ln );

extends 'HTML::FormHandler::Field::Text';

sub deflate {
    my ($self, $value) = @_;
    $value ||= $self->value;
    return MusicBrainz::Server::Track::FormatTrackLength($value);
}

sub validate
{
    my $self = shift;

    my $length = MusicBrainz::Server::Track::UnformatTrackLength($self->value);
    if ($length == -1) {
        $self->add_error(l('Not a valid time. Must be in the format MM:SS'));
        return;
    }

    $self->_set_value($length);
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
