package MusicBrainz::Server::Data::DurationLookup;
use JSON::XS qw( decode_json );
use Moose;
use namespace::autoclean -also => [qw( _parse_toc )];
use Readonly;
use MusicBrainz::Server::Entity::DurationLookupResult;
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Constants qw( $MAX_POSTGRES_INT );

with 'MusicBrainz::Server::Data::Role::Sql';
with 'MusicBrainz::Server::Data::Role::QueryToList';

Readonly our $DIMENSIONS => 6;

sub _parse_toc
{
    my ($toc) = @_;

    defined($toc) or return;
    $toc =~ s/\A\s+//;
    $toc =~ s/\s+\z//;
    $toc =~ /\A\d+(?: \d+)*\z/ or return;

    my ($firsttrack, $lasttrack, $leadoutoffset, @trackoffsets)
        = split ' ', $toc;

    $firsttrack == 1 or return;
    $lasttrack >=1 and $lasttrack <= 99 or return;
    @trackoffsets == $lasttrack or return;

    for (($firsttrack + 1) .. $lasttrack)
    {
        $trackoffsets[$_-1] > $trackoffsets[$_-1-1]
            or return;
    }

    $leadoutoffset > $trackoffsets[-1]
        or return;

    return (
        toc             => $toc,
        tracks          => scalar @trackoffsets,
        firsttrack      => $firsttrack,
        lasttrack       => $lasttrack,
        leadoutoffset   => $leadoutoffset,
        trackoffsets    => \@trackoffsets,
    );
}

sub lookup
{
    my ($self, $toc, $fuzzy, $all_formats, $limit, $offset) = @_;

    $toc =~ tr/+/ /;
    my %toc_info = _parse_toc($toc);
    return undef unless scalar(%toc_info);

    $limit //= 25;
    $offset //= 0;

    my @offsets = @{$toc_info{trackoffsets}};
    push @offsets, $toc_info{leadoutoffset};

    my (@durations, $i);
    for ($i = 0; $i < $toc_info{tracks}; $i++)
    {
        my $duration = int((($offsets[$i + 1] - $offsets[$i]) * 1000) / 75);

        return if $duration > $MAX_POSTGRES_INT;
        push @durations, $duration;
    }

    my $dur_string = q('{) . join(q(,), @durations) . q(}');

    $self->query_to_list_limited(
            "SELECT release,
                    min(cube_distance(toc, create_cube_from_durations($dur_string))) AS min_distance,
                    json_agg(json_build_object(
                        'medium', medium_index.medium,
                        'distance', cube_distance(toc, create_cube_from_durations($dur_string)),
                        'position', position
                    ) ORDER BY position) AS results
               FROM medium_index
               JOIN medium m ON medium_index.medium = m.id " .
               ($all_formats ? '' : ' LEFT JOIN medium_format mf ON m.format = mf.id ') . "
             WHERE  track_count_matches_cdtoc(m, ?)
                AND toc <@ create_bounding_cube($dur_string, ?) " .
                ($all_formats ? '' : ' AND (m.format IS NULL OR mf.has_discids) ') . '
           GROUP BY release
           ORDER BY min_distance, release
           LIMIT 25',
        [$toc_info{tracks}, $fuzzy], $limit, $offset, sub {
            my ($model, $row) = @_;
            return {
                release => $row->{release},
                min_distance => $row->{min_distance},
                results => decode_json($row->{results}),
            };
        });
}

sub update
{
    my ($self, $medium_id) = @_;

    # Disc should have an index if:
    #    1. the length of the disc is < 4800000
    #    2. all tracks on the disc have a length
    #    3. there are at most 99 tracks on the disc

    my $results = $self->sql->select_list_of_hashes(
        'SELECT (sum(track.length) < 4800000 AND
                 bool_and(track.length IS NOT NULL) AND
                 count(track.id) <= 99) AS should_have_index,
                medium_index.medium IS NOT NULL AS has_index
           FROM track
      LEFT JOIN medium_index ON medium_index.medium = track.medium
          WHERE track.medium = ? AND track.position > 0 AND track.is_data_track = false
       GROUP BY track.medium, medium_index.medium;', $medium_id);

    return unless @$results;

    my %disc = %{ $results->[0] };

    my $create_cube = 'create_cube_from_durations((
                    SELECT array(
                        SELECT t.length
                          FROM track t
                         WHERE medium = ? AND t.position > 0 AND t.is_data_track = false
                      ORDER BY t.position
                    )
            ))';

    if ($disc{has_index} && ! $disc{should_have_index})
    {
        $self->sql->delete_row('medium_index', { medium => $medium_id });
    }

    if ($disc{has_index} && $disc{should_have_index})
    {
        $self->sql->do(
            "UPDATE medium_index SET toc = $create_cube
              WHERE medium = ?", $medium_id, $medium_id);
    }

    if (! $disc{has_index} && $disc{should_have_index})
    {
        $self->sql->do(
            "INSERT INTO medium_index (medium, toc)
             VALUES (?, $create_cube)",
            $medium_id, $medium_id);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
