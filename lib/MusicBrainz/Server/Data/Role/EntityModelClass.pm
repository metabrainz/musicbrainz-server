package MusicBrainz::Server::Data::Role::EntityModelClass;

use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( type_to_model );

requires '_type';

sub _entity_class { 'MusicBrainz::Server::Entity::' . type_to_model(shift->_type) }

no Moose::Role;
1;

=head1 NAME

MusicBrainz::Server::Data::Role::EntityModelClass

=head1 DESCRIPTION

Define C<_entity_class> method assuming that
the value of C<_type> match the key of
an object literal in C<entities.json> file
with a C<model> subkey.

=head1 METHODS

=head2 _entity_class

Return the full name of the corresponding
C<MusicBrainz::Server::Entity> subclass.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
