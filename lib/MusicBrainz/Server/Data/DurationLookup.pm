package MusicBrainz::Server::Data::DurationLookup;
use Moose;
use namespace::autoclean -also => [qw( _parse_toc )];
use Readonly;
use MusicBrainz::Server::Entity::DurationLookupResult;
use MusicBrainz::Server::Entity::Medium;

with 'MusicBrainz::Server::Data::Role::Sql';

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
    my ($self, $toc, $fuzzy) = @_;

    $toc =~ s/\+/ /g;
    my %toc_info = _parse_toc($toc);
    return undef unless scalar(%toc_info);

    my @offsets = @{$toc_info{trackoffsets}};
    push @offsets, $toc_info{leadoutoffset};

    my (@durations, $i);
    for($i = 0; $i < $toc_info{tracks}; $i++)
    {
        push @durations, int((($offsets[$i + 1] - $offsets[$i]) * 1000) / 75);
    }

    my $dur_string = "'{" . join(",", @durations) . "}'";

    my $list = $self->sql->select_list_of_hashes(
            "SELECT medium_index.medium AS medium,
                    cube_distance(toc, create_cube_from_durations($dur_string)) AS distance,
                    release,
                    position,
                    format,
                    name,
                    edits_pending
               FROM medium_index
               JOIN medium ON medium_index.medium = medium.id
             WHERE  medium.track_count = ?
                AND toc <@ create_bounding_cube($dur_string, ?)
           ORDER BY distance", $toc_info{tracks}, $fuzzy);

    my @results;
    foreach my $item (@{$list})
    {
        my $result = MusicBrainz::Server::Entity::DurationLookupResult->new();
        $result->distance(int($item->{distance}));
        $result->medium_id($item->{medium});
        my $medium = MusicBrainz::Server::Entity::Medium->new();
        $medium->id($item->{medium});
        $medium->release_id($item->{release});
        $medium->position($item->{position});
        $medium->format_id($item->{format}) if $item->{format};
        $medium->name($item->{name} or '');
        $medium->edits_pending($item->{edits_pending});
        $result->medium($medium);
        push @results, $result;
    }
    return \@results;
}

sub update
{
    my ($self, $medium_id) = @_;

    # Disc should have an index if:
    #    1. the length of the disc is < 4800000
    #    2. all tracks on the disc have a length
    #    3. there are at most 99 tracks on the disc

    my $results = $self->sql->select_list_of_hashes (
        "SELECT (sum(track.length) < 4800000 AND
                 bool_and(track.length IS NOT NULL) AND
                 count(track.id) <= 99) AS should_have_index,
                medium_index.medium IS NOT NULL AS has_index
           FROM track
      LEFT JOIN medium_index ON medium_index.medium = track.medium
          WHERE track.medium = ?
       GROUP BY track.medium, medium_index.medium;", $medium_id);

    return unless $results;

    my %disc = %{ $results->[0] };

    my $create_cube = 'create_cube_from_durations((
                    SELECT array(
                        SELECT t.length
                          FROM track t
                         WHERE medium = ?
                      ORDER BY t.position
                    )
            ))';

    if ($disc{has_index} && ! $disc{should_have_index})
    {
        $self->sql->delete_row ("medium_index", { medium => $medium_id });
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

=head1 COPYRIGHT

Copyright (C) 2009 Robert Kaye

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
