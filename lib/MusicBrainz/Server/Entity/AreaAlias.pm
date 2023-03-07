package MusicBrainz::Server::Entity::AreaAlias;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Alias';

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'AreaAliasType' };

sub entity_type { 'area_alias' }

has 'area_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'area' => (
    is => 'rw',
    isa => 'Area'
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
