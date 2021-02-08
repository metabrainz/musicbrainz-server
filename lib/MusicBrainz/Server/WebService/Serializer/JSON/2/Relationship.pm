package MusicBrainz::Server::WebService::Serializer::JSON::2::Relationship;
use Moose;
use List::AllUtils qw( any );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    number
    serialize_date_period
    serialize_entity
    serialize_type
);

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub element { 'relation'; }

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my $body = {};
    my @attributes = $entity->link->all_attributes;

    serialize_type($body, $entity->link, $inc, $opts, 1);

    $body->{direction} = $entity->direction == 2 ? "backward" : "forward";
    $body->{'ordering-key'} = number($entity->link_order) if $entity->link_order;

    serialize_date_period($body, $entity->link);

    $body->{attributes} = [ map { $_->type->name } @attributes ];

    $body->{"attribute-values"} = {
        map {
            non_empty($_->text_value) ? ($_->type->name => $_->text_value) : ()
        }
        @attributes
    };

    $body->{"attribute-ids"} = {
        map {
            $_->type->name => $_->type->gid
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
