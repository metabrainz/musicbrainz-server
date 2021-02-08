package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );

parameter 'property' => (
    isa => 'Str',
    required => 0,
    default => sub { 'location' }
);

parameter 'include_birth_death' => (
    isa => 'CodeRef',
    required => 0,
    default => sub { sub { 0 } }
);

role {
    my $params = shift;
    my $property = $params->property;
    my $include = $params->include_birth_death;

    requires 'serialize';
    around serialize => sub {
        my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
        my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

        $ret->{$property} = serialize_entity($entity->area, $inc, $stash) if $entity->area;
        if ($include->($entity)) {
            $ret->{birthPlace} = serialize_entity($entity->begin_area, $inc, $stash) if $entity->can('begin_area') && $entity->begin_area;
            $ret->{deathPlace} = serialize_entity($entity->end_area, $inc, $stash) if $entity->can('end_area') && $entity->end_area;
        }

        return $ret;
    };
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

