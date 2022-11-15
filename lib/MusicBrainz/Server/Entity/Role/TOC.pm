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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
