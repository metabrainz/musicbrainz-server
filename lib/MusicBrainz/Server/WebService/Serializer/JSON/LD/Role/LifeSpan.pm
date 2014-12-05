package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan;
use MooseX::Role::Parameterized;
use DateTime::Format::ISO8601;
use aliased 'MusicBrainz::Server::Entity::PartialDate';

parameter 'begin_properties' => (
    isa => 'CodeRef',
    required => 0,
    default => sub { sub { qw( foundingDate ) } }
);

parameter 'end_properties' => (
    isa => 'CodeRef',
    required => 0,
    default => sub { sub { qw( dissolutionDate ) } }
);

role {
    my $params = shift;
    my $begin_properties = $params->begin_properties;
    my $end_properties = $params->end_properties;

    around serialize => sub {
        my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
        my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

        # Note: This uses foundingDate and dissolutionDate, which are
        # technically only applicable to organizations, and should refer to
        # the start/end dates of the career. This does not match our usage for
        # Person-type artists, but we also still (as requested) mark these as
        # MusicGroups, i.e. organizations.
        #
        # There may be a better way to do this, but I'm not really sure what
        # exactly it is.
        if ($entity->begin_date && $entity->begin_date->defined_run) {
            my @run = $entity->begin_date->defined_run;
            my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
            for my $property ($begin_properties->($entity)) {
                $ret->{$property} = $date->format;
            }
        }
        if ($entity->end_date && $entity->end_date->defined_run) {
            my @run = $entity->end_date->defined_run;
            my $date = PartialDate->new(year => $run[0], month => $run[1], day => $run[2]);
            for my $property ($end_properties->($entity)) {
                $ret->{$property} = $date->format;
            }
        }

        return $ret;
    };
};

no Moose::Role;
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

