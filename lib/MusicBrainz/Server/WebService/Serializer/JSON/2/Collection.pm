package MusicBrainz::Server::WebService::Serializer::JSON::2::Collection;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    list_of
    number
);
use MusicBrainz::Server::Constants qw( %ENTITIES );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize {
    my ($self, $entity, $inc, $stash, $toplevel) = @_;

    my %body;
    my $entity_type = $entity->type->item_entity_type;

    $body{name} = $entity->name;
    $body{editor} = $entity->editor->name;
    $body{'entity-type'} = $entity_type;

    my $entity_properties = $ENTITIES{$entity_type};
    my $plural = $entity_properties->{plural};
    my $plural_url = $entity_properties->{plural_url};
    my $url = $entity_properties->{url};

    if ($toplevel) {
        my $items = $stash->store($entity)->{$plural}->{items} // [];

        if (@$items) {
            $body{$plural_url} = list_of($entity, $inc, $stash, $plural);
        }
    }

    $body{"$url-count"} = number($entity->entity_count);
    return \%body;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
