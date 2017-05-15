package MusicBrainz::Server::Data::Role::ISNI;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils qw( type_to_model );

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

role
{
    my $params = shift;

    my $entity_type = $params->type;

    with 'MusicBrainz::Server::Data::Role::ValueSet' => {
        entity_type         => $entity_type,
        plural_value_type   => 'isni_codes',
        value_attribute     => 'isni',
        value_class         => type_to_model($entity_type) . 'ISNI',
        value_type          => 'isni',
    };

};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012-2017 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

