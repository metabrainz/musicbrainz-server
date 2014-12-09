package MusicBrainz::Server::WebService::Serializer::JSON::LD::Artist;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan' =>
    { begin_properties => sub { my $artist = shift; return ($artist->type && $artist->type->name eq 'Person') ? qw( foundingDate birthDate ) : qw( foundingDate ) },
      end_properties   => sub { my $artist = shift; return ($artist->type && $artist->type->name eq 'Person')  ? qw( dissolutionDate deathDate ) : qw( dissolutionDate ) } };
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Area' => { include_birth_death => sub { my $artist = shift; return $artist->type && $artist->type->name eq 'Person' } };

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    if ($toplevel) {
        $ret->{'@type'} = ($entity->type && $entity->type->name eq 'Person') ? ['Person', 'MusicGroup'] : 'MusicGroup';
        $ret->{groupOrigin} = serialize_entity($entity->begin_area, $inc, $stash) if $entity->begin_area;

        my @members = grep { $_->direction == 2 } @{ $entity->relationships_by_link_type_names('member of band') };
        if (@members) {
            $ret->{'member'} = [map { member_relationship($_, $inc, $stash) } @members]
        }
    }

    return $ret;
};

sub member_relationship {
    my ($relationship, $inc, $stash) = @_;
    my $ret = { member => serialize_entity($relationship->target, $inc, $stash) };

    if ($relationship->link->begin_date && $relationship->link->begin_date->defined_run) {
        my @run = $relationship->link->begin_date->defined_run;
        my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
        $ret->{startDate} = $date->format;
    }
    if ($relationship->link->end_date && $relationship->link->end_date->defined_run) {
        my @run = $relationship->link->end_date->defined_run;
        my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
        $ret->{endDate} = $date->format;
    }
    # TODO: roles
    return $ret;
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

