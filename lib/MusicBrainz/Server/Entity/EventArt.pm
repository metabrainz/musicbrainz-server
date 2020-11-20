package MusicBrainz::Server::Entity::EventArt;

use Moose;
use DBDefs;
use MusicBrainz::Server::Entity::EventArtType;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Art';

has '+types' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::EventArtType]',
);

has event_id => (
    is => 'rw',
    isa => 'Int',
);

has event => (
    is => 'rw',
    isa => 'Event',
);

sub _entity { shift->event }

sub _ia_entity { shift->event }

sub _download_prefix { DBDefs->EVENT_ART_ARCHIVE_DOWNLOAD_PREFIX }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
