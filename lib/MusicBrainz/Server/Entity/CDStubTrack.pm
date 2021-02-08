package MusicBrainz::Server::Entity::CDStubTrack;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'cdstub_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'cdstub' => (
    is => 'rw',
    isa => 'CDStub'
);

has 'title' => (
    is => 'rw',
    isa => 'Str'
);

has 'artist' => (
    is => 'rw',
    isa => 'Str'
);

has 'sequence' => (
    is => 'rw',
    isa => 'Int'
);

has 'length' => (
    is => 'rw',
    isa => 'Int'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
