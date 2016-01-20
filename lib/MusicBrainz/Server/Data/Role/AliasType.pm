package MusicBrainz::Server::Data::Role::AliasType;

use Moose::Role;
use MusicBrainz::Server::Entity::AliasType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

with 'MusicBrainz::Server::Data::Role::OptionsTree';

sub _columns { 'id, name, parent AS parent_id, child_order, description' }

sub _entity_class { 'MusicBrainz::Server::Entity::AliasType' }

sub load {
    my ($self, @objs) = @_;

    load_subobjects($self, 'type', @objs);
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2016 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
