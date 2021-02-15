package MusicBrainz::Server::WebService::Serializer::JSON::2::Label;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of number serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{"sort-name"} = $entity->name;
    $body{"label-code"} = number($entity->label_code);
    $body{disambiguation} = $entity->comment // "";

    if ($toplevel)
    {
        $body{country} = $entity->area && $entity->area->country_code ? $entity->area->country_code : JSON::null;
        $body{area} = $entity->area ? serialize_entity($entity->area) : JSON::null;

        $body{releases} = list_of($entity, $inc, $stash, "releases")
            if ($inc && $inc->releases);
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

