package MusicBrainz::Server::Data::Role::EntityModelClass;

use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( %ENTITIES );

# '_type' is indirectly required.

sub _entity_class { 'MusicBrainz::Server::Entity::' . $ENTITIES{shift->_type}{model} }

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009,2011 Lukas Lalinsky
Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
