package MusicBrainz::Server::Entity::CentralEntity;

use Moose;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';
with 'MusicBrainz::Server::Entity::Role::GID';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Relatable';
with 'MusicBrainz::Server::Entity::Role::Name';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Entity::CentralEntity

=head1 DESCRIPTION

Central entities can have edits, GIDs, relationships,
search indexes and webservice endpoints, all at once.

Historically they were named "core" entities in code, "primary"
entities in API documentation, and just "MusicBrainz" entities
anywhere else. Because "core" was also used with other meanings
(some entities, public domain data, search indexes) it has been
replaced by "central" which matches the above definition only.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
