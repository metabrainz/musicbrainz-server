package MusicBrainz::Server::Data::EventArtType;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::ArtType';

sub _type { 'event_art_type' }

sub art_schema { 'event_art_archive' }

sub art_type_table { 'event_art_archive.event_art_type' }

sub _entity_class { 'MusicBrainz::Server::Entity::EventArtType' }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
