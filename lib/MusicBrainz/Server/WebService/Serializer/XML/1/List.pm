package MusicBrainz::Server::WebService::Serializer::XML::1::List;
use Moose;

use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serializer serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

has '_element' => (
    is => 'rw',
    isa => 'Str',
);

sub element { return $_[0]->_element . '-list'; }

before 'serialize' => sub 
{
    my ($self, $entities, $inc, $opts) = @_;

    return unless $entities && @$entities;

    $self->_element( serializer($entities->[0])->new->element );

    map { $self->add( serialize_entity($_) ) } @$entities;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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

