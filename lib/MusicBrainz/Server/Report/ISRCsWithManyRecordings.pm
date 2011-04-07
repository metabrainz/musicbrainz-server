package MusicBrainz::Server::Report::ISRCsWithManyRecordings;
use Moose;

extends 'MusicBrainz::Server::Report';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT i.isrc, recordingcount, r.gid, tn.name, r.length, r.artist_credit AS artist_credit_id
        FROM isrc i
          JOIN recording r ON (r.id = i.recording)
          JOIN track_name tn ON (r.name = tn.id)
          JOIN (
           SELECT isrc, count(*) AS recordingcount
            FROM isrc
            GROUP BY isrc HAVING count(*) > 1
          ) t ON t.isrc = i.isrc
        ORDER BY recordingcount DESC, i.isrc
    ");
}

sub post_load
{
    my ($self, $items) = @_;

    my @ids = map { $_->{artist_credit_id} } @$items;
    my $acs = $self->c->model('ArtistCredit')->get_by_ids(@ids);
    foreach my $item (@$items) {
        $item->{artist_credit} = $acs->{$item->{artist_credit_id}};
    }
}

__PACKAGE__->meta->make_immutable;
sub template
{
    return 'report/isrc_with_many_recordings.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
