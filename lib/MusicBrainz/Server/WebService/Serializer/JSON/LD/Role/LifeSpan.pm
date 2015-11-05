package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::LifeSpan;
use MooseX::Role::Parameterized;
use DateTime::Format::ISO8601;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( format_date );
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

        # Note: For artist groups, This uses foundingDate and dissolutionDate,
        # which are technically only applicable to organizations, and should
        # refer to the start/end dates of the career.
        #
        # There may be a better way to do this, but I'm not really sure what
        # exactly it is.
        if ($toplevel) {
            if (my $begin_date = format_date($entity->begin_date)) {
                for my $property ($begin_properties->($entity)) {
                    $ret->{$property} = $begin_date;
                }
            }
            if (my $end_date = format_date($entity->end_date)) {
                for my $property ($end_properties->($entity)) {
                    $ret->{$property} = $end_date;
                }
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

