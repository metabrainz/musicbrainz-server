package MusicBrainz::Server::Data::Role::AliasType;

use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::AliasType;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

with 'MusicBrainz::Server::Data::Role::OptionsTree';

sub _columns { 'id, gid, name, parent AS parent_id, child_order, description' }

sub load {
    my ($self, @objs) = @_;

    load_subobjects($self, 'type', @objs);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
