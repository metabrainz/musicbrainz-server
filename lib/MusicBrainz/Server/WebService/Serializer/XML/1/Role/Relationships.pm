package MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships;
use Moose::Role;

use List::UtilsBy 'sort_by';
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of map_type );

requires 'serialize';

around serialize => sub
{
    my ($orig, $self, $entity, $inc, $opts) = @_;
    my @body = $self->$orig($entity, $inc, $opts);

    if ($inc && $inc->has_rels) {
        my %by_type = map { $_ => [] } @{$inc->get_rel_types};
        for my $relationship (@{ $entity->relationships }) {
            $by_type{ $relationship->target_type } or next;

            push @{ $by_type{ $relationship->target_type } },
                $relationship;
        }

        for my $type (grep { @{ $by_type{$_} } } sort keys %by_type) {
            my $relationships = $by_type{$type};

            push @body, (
                list_of(
                    { 'target-type' => map_type($type) },
                    [
                        sort_by { $_->target_key . $_->link->type->name }
                            @$relationships
                    ])
            )
        }
    }

    return @body;
};

no Moose::Role;
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

