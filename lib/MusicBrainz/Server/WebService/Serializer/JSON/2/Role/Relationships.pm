package MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships;
use Moose::Role;

use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(serialize_entity);

requires 'serialize';

around serialize => sub
{
    my ($orig, $self, $entity, $inc, $opts, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $opts, $toplevel);

    return $ret unless defined $inc && $inc->has_rels;

    my @rels = map { serialize_entity ($_) }
        sort_by { $_->target_key . $_->link->type->name }
            @{ $entity->relationships };

    $ret->{relations} = \@rels;

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2010,2012 MetaBrainz Foundation

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

