package MusicBrainz::Server::Entity::Role::TOC;
use Moose::Role;
use namespace::autoclean;

requires qw(
    track_count
    leadout_offset
    track_offset
);

sub toc {
    my $self = shift;
    return join(' ', '1', $self->track_count, $self->leadout_offset,
                @{ $self->track_offset });
}

1;
