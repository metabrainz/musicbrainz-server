package MusicBrainz::Server::WebService::Serializer::JSON::2::ISRC;

use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize {
    my ($self, $isrcs, $inc, $stash) = @_;

    return {
        isrc => $isrcs->[0]->name,
        recordings => [map { serialize_entity($_->recording, $inc, $stash) } @$isrcs],
    };
};

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2016 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
