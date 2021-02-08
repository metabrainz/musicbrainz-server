package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Producer;
use Moose::Role;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity list_or_single );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my @producers = @{ $entity->relationships_by_link_type_names('producer') };
    if (@producers) {
        $ret->{producer} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @producers);
    }

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

