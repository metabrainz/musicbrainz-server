package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID;
use Moose::Role;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use DBDefs;

with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::SameAs';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    my $entity_type = ref_to_type($entity);
    my $entity_url = $ENTITIES{$entity_type}{url} // $entity_type;

    $ret->{'@id'} = DBDefs->CANONICAL_SERVER . '/' . $entity_url . '/' . $entity->gid;

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

