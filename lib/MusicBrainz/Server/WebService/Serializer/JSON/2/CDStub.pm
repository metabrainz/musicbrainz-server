package MusicBrainz::Server::WebService::Serializer::JSON::2::CDStub;
use Moose;
use JSON;

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $cdstub, $inc, $stash, $toplevel) = @_;

    return {
        id => $cdstub->discid,
        title => $cdstub->title,
        artist => $cdstub->artist,
        barcode => $cdstub->barcode->format || JSON::null,
        disambiguation => $cdstub->comment || '',
        tracks => [
            map +{
                title => $_->title,
                artist => $_->artist || JSON::null,
                length => $_->length
            }, $cdstub->all_tracks
        ],
        'track-count' => $cdstub->track_count
    };
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
