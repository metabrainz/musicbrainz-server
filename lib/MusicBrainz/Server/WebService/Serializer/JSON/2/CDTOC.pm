package MusicBrainz::Server::WebService::Serializer::JSON::2::CDTOC;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of number );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{id} = $entity->discid;
    $body{'offset-count'} = number($entity->track_count);
    $body{sectors} = number($entity->leadout_offset);

    my @list;
    foreach my $track (0 .. ($entity->track_count - 1)) {
        push @list, number($entity->track_offset->[$track]);
    }

    if (scalar @list) {
        $body{offsets} = \@list;
    }

    if ($toplevel)
    {
        $body{releases} = list_of($entity, $inc, $stash, 'releases', $toplevel);
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
