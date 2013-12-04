package MusicBrainz::Server::Report::FeaturingRecordings;
use Moose;

with 'MusicBrainz::Server::Report::RecordingReport',
     'MusicBrainz::Server::Report::FilterForEditor::RecordingID';

sub query {
    "
        SELECT
            r.id AS recording_id,
            row_number() OVER (ORDER BY musicbrainz_collate(ac.name), musicbrainz_collate(r.name))
        FROM recording r
            JOIN artist_credit ac ON r.artist_credit = ac.id
        WHERE
            r.name ~ E' \\\\(feat\\\\. '
    "
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

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
