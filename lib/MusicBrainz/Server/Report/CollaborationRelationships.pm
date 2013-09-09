package MusicBrainz::Server::Report::CollaborationRelationships;
use Moose;

with 'MusicBrainz::Server::Report::QueryReport',
     'MusicBrainz::Server::Report::FilterForEditor';

sub query {
    "
        SELECT
            artist0.id AS id0, artist0.name AS name0, artist1.id AS id1, artist1.name AS name1,
            row_number() OVER (
              ORDER BY musicbrainz_collate(artist1.name), artist1.id, musicbrainz_collate(artist0.name), artist0.id
            )
        FROM
            l_artist_artist
            JOIN link ON link.id=l_artist_artist.link
            JOIN link_type ON link_type.id=link.link_type
            JOIN artist AS artist0 ON l_artist_artist.entity0=artist0.id
            JOIN artist AS artist1 ON l_artist_artist.entity1=artist1.id
            LEFT JOIN l_artist_url ON l_artist_artist.entity1=l_artist_url.entity0
        WHERE
            link_type.name = 'collaboration' AND
            l_artist_url.id IS NULL
    ";
}

sub inflate_rows
{
    my ($self, $items) = @_;
    my $artists = $self->c->model('Artist')->get_by_ids(
        map { $_->{id0}, $_->{id1} } @$items
    );

    return [
        map +{
            %$_,
            artist0 => $artists->{$_->{id0}},
            artist1 => $artists->{$_->{id1}}
        }, @$items
    ];
}

sub filter_sql {
    my ($self, $editor_id) = @_;
    my $tbl = $self->qualified_table;
    return (
        "WHERE report.id1 IN (
           SELECT id1 FROM $tbl inner_report
           JOIN editor_subscribe_artist esa ON esa.artist = inner_report.id0 OR esa.artist = inner_report.id1
           WHERE esa.editor = ?
         )",
        $editor_id
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 MetaBrainz Foundation
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
