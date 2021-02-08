package MusicBrainz::Server::Entity::TrackChangesPreview;

use Moose;
use MusicBrainz::Server::Entity::Types;

has $_ => (
    is  => 'rw',
    isa => 'Int',
    default => 0
) for qw( deleted renamed );

has 'track' => (
    is => 'rw',
    isa => 'Track',
);

has 'suggestions' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::SearchResult]',
    lazy => 1,
    default => sub { [] },
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
