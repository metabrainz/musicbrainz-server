package MusicBrainz::Server::WebService::Serializer::JSON::2::ISRC;

use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize {
    my ($self, $isrc, $inc, $stash) = @_;

    my $opts = $stash->store($isrc);
    my @recordings = @{ $opts->{recordings}{items} };

    return {
        isrc => $isrc->name,
        recordings => [map { serialize_entity($_, $inc, $stash) } @recordings],
    };
};

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
