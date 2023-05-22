# Automatically generated, do not edit.
package MusicBrainz::Server::Data::GenreAliasType;

use Moose;
use MusicBrainz::Server::Entity::GenreAliasType;

extends 'MusicBrainz::Server::Data::Entity';

with 'MusicBrainz::Server::Data::Role::AliasType';

sub _entity_class { 'MusicBrainz::Server::Entity::GenreAliasType' }

sub _table { 'genre_alias_type' }

sub _type { 'genre_alias_type' }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut