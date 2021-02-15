package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases;
use Moose::Role;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use List::AllUtils qw( uniq );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);
    return $ret unless $toplevel;

    my $alternateNames = $ret->{alternateName} // [];

    my $entity_type = ref_to_type($entity);
    my $entity_search_hint_type = $ENTITIES{$entity_type}{aliases}{search_hint_type};

    my $opts = $stash->store($entity);

    for my $alias (grep { ($_->type_id // 0) != $entity_search_hint_type } @{ $opts->{aliases} // [] })
    {
        push @$alternateNames, $alias->name;
    }

    $ret->{alternateName} = [uniq @$alternateNames] if @$alternateNames;

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

