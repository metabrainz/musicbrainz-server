package MusicBrainz::Server::WebService::Serializer::XML::1::Editor;
use Moose;

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

sub element { 'ext:user'; }

sub attributes {
    my ($self, $entity) = @_;

    my @types;
    push @types, "AutoEditor" if $entity->is_auto_editor;
    push @types, "RelationshipEditor" if $entity->is_relationship_editor;
    push @types, "Bot" if $entity->is_bot;

    return (
        type => join (' ', @types) || ''
    )
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;

    return (
        $self->gen->name($entity->name),
        $self->gen->${ \'ext:nag' }(
            { show => 'false' }
        )
    )
}

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

