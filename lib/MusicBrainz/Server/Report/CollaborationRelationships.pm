package MusicBrainz::Server::Report::CollaborationRelationships;
use Moose;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport',
     'MusicBrainz::Server::Report::FilterForEditor';

sub query {
    "
        SELECT
            artist0.id AS id0, artist0.name AS name0, artist1.id AS id1, artist1.name AS name1,
            row_number() OVER (
              ORDER BY artist1.name COLLATE musicbrainz, artist1.id, artist0.name COLLATE musicbrainz, artist0.id
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
            artist0 => to_json_object($artists->{ $_->{id0} }),
            artist1 => to_json_object($artists->{ $_->{id1} }),
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
