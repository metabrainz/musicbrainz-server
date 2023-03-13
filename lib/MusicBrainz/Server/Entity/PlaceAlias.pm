package MusicBrainz::Server::Entity::PlaceAlias;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Alias';

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'PlaceAliasType' };

sub entity_type { 'place_alias' }

has 'place_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'place' => (
    is => 'rw',
    isa => 'Place'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
