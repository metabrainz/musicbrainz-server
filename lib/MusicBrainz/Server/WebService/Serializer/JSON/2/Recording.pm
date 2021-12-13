package MusicBrainz::Server::WebService::Serializer::JSON::2::Recording;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    boolean
    number
    serialize_entity
    list_of
);
use List::AllUtils qw( sort_by );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{disambiguation} = $entity->comment // '';
    $body{length} = number($entity->length);
    $body{video} = boolean($entity->video);

    if ($entity->artist_credit && ($toplevel || ($inc && $inc->artist_credits))) {
        $body{'artist-credit'} = serialize_entity($entity->artist_credit, $inc, $stash);
    }

    $body{releases} = list_of($entity, $inc, $stash, 'releases')
        if ($toplevel && $inc && $inc->releases);

    if ($inc && $inc->isrcs) {
        my $opts = $stash->store($entity);
        $body{isrcs} = [
            map { $_->isrc } sort_by { $_->isrc } @{ $opts->{isrcs} }
        ];
    }

    if (defined $entity->first_release_date) {
        $body{'first-release-date'} = $entity->first_release_date->format;
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

