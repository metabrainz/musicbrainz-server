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

    return unless $self->sql->select_single_value(
        'SELECT 1 FROM medium
           JOIN track ON track.medium = medium.id
          WHERE medium.id = ?
         HAVING count(medium.id) <= 99
            AND sum(track.length) < 4800000',
        $medium_id
    );

    my $create_cube = 'create_cube_from_durations((
                    SELECT array(
                        SELECT t.length
                          FROM track t
                         WHERE medium = ?
                      ORDER BY t.position
                    )
            ))';

    if ($self->sql->select_single_value(
        'SELECT 1 FROM medium_index WHERE medium = ?', $medium_id
    )) {
        $self->sql->do(
            "UPDATE medium_index SET toc = $create_cube
              WHERE medium = ?", $medium_id, $medium_id);
    }
    else {
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
