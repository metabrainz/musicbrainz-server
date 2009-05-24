package MusicBrainz::Server::Data::Search;

use Moose;
use Sql;
use Readonly;
use MusicBrainz::Server::Entity::SearchResult;
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Data::Recording;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Work;

extends 'MusicBrainz::Server::Data::Entity';

Readonly my %TYPE_TO_DATA_CLASS => (
    artist        => 'MusicBrainz::Server::Data::Artist',
    label         => 'MusicBrainz::Server::Data::Label',
    recording     => 'MusicBrainz::Server::Data::Recording',
    release       => 'MusicBrainz::Server::Data::Release',
    release_group => 'MusicBrainz::Server::Data::ReleaseGroup',
    work          => 'MusicBrainz::Server::Data::Work',
);

sub search
{
    my ($self, $type, $query_str, $limit, $offset) = @_;
    return ([], 0) unless $query_str && $type;

    $offset ||= 0;

    my $query;
    my $use_hard_search_limit = 1;
    my $hard_search_limit;

    if ($type eq "artist" || $type eq "label") {
        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.comment,
                aname.name AS name,
                asortname.name AS sortname,
                MAX(rank) AS rank
            FROM
                (
                    SELECT id, ts_rank_cd(to_tsvector('mb_simple', name), query, 16) AS rank
                    FROM ${type}_name, plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                LEFT JOIN ${type}_alias AS alias ON alias.name = r.id
                JOIN ${type} AS entity ON (r.id = entity.name OR r.id = entity.sortname OR alias.${type} = entity.id)
                JOIN ${type}_name AS aname ON entity.name = aname.id
                JOIN ${type}_name AS asortname ON entity.sortname = asortname.id
            GROUP BY
                entity.id, entity.gid, entity.comment, aname.name, asortname.name
            ORDER BY
                rank DESC, sortname, name
            OFFSET
                ?
        ";
        $hard_search_limit = $offset * 2;
    }
    elsif ($type eq "recording" || $type eq "release" || $type eq "release_group" || $type eq "work") {
        my $type2 = $type;
        $type2 = "track" if $type eq "recording";
        $type2 = "release" if $type eq "release_group";
        $query = "
            SELECT
                entity.id,
                entity.gid,
                entity.comment,
                entity.artist_credit AS artist_credit_id,
                r.name,
                r.rank
            FROM
                (
                    SELECT id, name, ts_rank_cd(to_tsvector('mb_simple', name), query, 16) AS rank
                    FROM ${type2}_name, plainto_tsquery('mb_simple', ?) AS query
                    WHERE to_tsvector('mb_simple', name) @@ query
                    ORDER BY rank DESC
                    LIMIT ?
                ) AS r
                JOIN ${type} entity ON r.id = entity.name
            ORDER BY
                r.rank DESC, r.name, artist_credit
            OFFSET
                ?
        ";
        $hard_search_limit = int($offset * 1.2);
    }

    if ($use_hard_search_limit) {
        $hard_search_limit += $limit * 3;
    }

    my $fuzzy_search_limit = 10000;
    my $search_timeout = 60 * 1000;

    my $sql = Sql->new($self->c->mb->dbh);
    $sql->AutoCommit(1);
    $sql->Do('SET SESSION gin_fuzzy_search_limit TO ?', $fuzzy_search_limit);
    $sql->AutoCommit(1);
    $sql->Do('SET SESSION statement_timeout TO ?', $search_timeout);

    if ($use_hard_search_limit) {
        $sql->Select($query, $query_str, $hard_search_limit, $offset);
    }
    else {
        $sql->Select($query, $query_str, $offset);
    }

    my @result;
    my $pos = $offset + 1;
    while ($limit--) {
        my $row = $sql->NextRowHashRef or last;
        my $res = MusicBrainz::Server::Entity::SearchResult->new(
            position => $pos++,
            score => int(100 * $row->{rank}),
            entity => $TYPE_TO_DATA_CLASS{$type}->_new_from_row($row)
        );
        push @result, $res;
    }
    my $hits = $sql->Rows + $offset;
    $sql->Finish;
    return (\@result, $hits);

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::Search

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
