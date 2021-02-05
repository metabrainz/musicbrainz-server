package MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Length;
use Moose::Role;
use MusicBrainz::Server::Track qw( format_iso_duration );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    if ($entity->length) {
        $ret->{duration} = format_iso_duration($entity->length);
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

