package MusicBrainz::Server::Entity::CoreEntity;

use Moose;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';
with 'MusicBrainz::Server::Entity::Role::GID';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Name';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
