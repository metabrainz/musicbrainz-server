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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

