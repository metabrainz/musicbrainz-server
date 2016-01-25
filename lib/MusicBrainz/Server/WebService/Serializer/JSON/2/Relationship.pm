package MusicBrainz::Server::WebService::Serializer::JSON::2::Relationship;
use Moose;
use Hash::Merge qw( merge );
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    date_period
    number
    serialize_entity
);

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub element { 'relation'; }

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my $body;
    my @attributes = $entity->link->all_attributes;

    $body->{type} = $entity->link->type->name;
    $body->{"type-id"} = $entity->link->type->gid;
    $body->{direction} = $entity->direction == 2 ? "backward" : "forward";
    $body->{'ordering-key'} = number($entity->link_order) if $entity->link_order;

    $body = merge($body, date_period($entity->link));
    $body->{attributes} = [ map { $_->type->name } @attributes ];

    $body->{"attribute-values"} = {
        map {
            non_empty($_->text_value) ? ($_->type->name => $_->text_value) : ()
        }
        @attributes
    };

    $body->{"attribute-credits"} = {
        map {
            non_empty($_->credited_as) ? ($_->type->name => $_->credited_as) : ()
        }
        @attributes
    } if any { $_->type->creditable } @attributes;

    $body->{'target-type'} = $entity->target_type;
    $body->{$entity->target_type} = serialize_entity($entity->target, $inc, $opts);
    $body->{'source-credit'} = $entity->source_credit // '';
    $body->{'target-credit'} = $entity->target_credit // '';

    return $body;
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
