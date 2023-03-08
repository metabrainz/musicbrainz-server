# Automatically generated, do not edit.
package MusicBrainz::Server::Entity::ReleaseAliasType;

use Moose;

extends 'MusicBrainz::Server::Entity::AliasType';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'ReleaseAliasType',
};

sub entity_type { 'release_alias_type' }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
