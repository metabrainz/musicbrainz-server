package MusicBrainz::Server::Controller::ReleaseEditor;
use Moose;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::Entity::TrackChangesPreview';

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub artist_compare
{
    return 0;
}

sub recording_suggestions
{
    my ($c, $changes, @prepend) = @_;

    # FIXME: should probably use the search server here, it allows easier ranking
    # of results where both recording name and artist name are taken into account.

    my ($results, $hits) = 
        $c->model('Search')->search ('recording', $changes->track->name, 10);

    $changes->suggestions ([ @prepend, map { $_->entity } @$results ]);
}

sub track_add
{
    my ($c, $newdata) = @_;

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});
    my $new = Track->new($newdata);
    
    my $t = TrackChangesPreview->new (added => 1, track => $new);

    recording_suggestions ($c, $t);

    return $t;
}

sub _warn_track
{
    my ($which, $track) = @_;

    warn "$which: ".$track->position.". ".$track->name." / ".$track->artist_credit->name."\n";
}


sub track_compare
{
    my ($c, $old, $newdata) = @_;

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});
    my $new = Track->new($newdata);
    my $preview = TrackChangesPreview->new (track => $new, old => $old);

    _warn_track ("OLD", $old);
    _warn_track ("NEW", $new);

    $preview->deleted(1) if $newdata->{deleted};
    $preview->renamed(1) if $old->name ne $new->name;
    $preview->moved(1)   if $old->position ne $new->position;
    $preview->length(1)  if $old->length ne $new->length;
    $preview->artist(1)  if artist_compare ($c, $old->artist_credit, $new->artist_credit);

    my @suggest;
    if ($old->id == $new->id)
    {
        # if this track is already linked to a recording, add that recording as
        # the first suggestion.
        @suggest = ( $old->recording );
    }

    if ($preview->renamed)
    {
        # the track was renamed, tying it to the old recording (which probably still
        # has the old track name) may be a mistake.  Search for similar recordings to
        # offer the user a choice.

        recording_suggestions ($c, $preview, @suggest);
    }
    else
    {
        $preview->suggestions (\@suggest);
    }

    return $preview;
}

sub tracklist_compare
{
    my ($c, $old_medium, $new_medium) = @_;

    # first, only check moves/deletes.
    my @new = @{ $new_medium->{tracklist}->{tracks} };
    my @old = @{ $old_medium->tracklist->tracks };

    my $maxnew = scalar @new;
    my $maxold = scalar @old;

    my @to_delete;
    for (my $i = $maxold; $i < $maxnew; $i++)
    {
        my $trackpos = $new[$i]->{position} - 1;

        next if ($i == $trackpos);

        if ($new[$trackpos]->{deleted})
        {
            my $recording_backup = $new[$trackpos]->{id}; 
            $new[$trackpos] = $new[$i];
            $new[$trackpos]->{id} = $recording_backup;

            push @to_delete, $i;
        }
    }

    # delete new tracks which replace existing tracks (moves/renames).
    while (@to_delete)
    {
        delete($new[pop @to_delete]);
    }

    my @ret;
    while (@old)
    {
        push @ret, track_compare ($c, shift @old, shift @new);
    }

    # any tracks left over after removing new tracks which replace existing
    # tracks are added tracks.
    while (@new)
    {
        push @ret, track_add ($c, shift @new);
    }
    
    return \@ret;
}

sub release_compare
{
    my ($c, $release, $data) = @_;

    my @old_media = @{ $release->mediums };
    my @new_media = @{ $data->{mediums} };

    if (scalar @old_media != scalar @new_media)
    {
        die ("adding/removing discs is not yet supported.\n");
    }

    my @ret;
    while (@old_media)
    {
        push @ret, tracklist_compare ($c, shift @old_media, shift @new_media);
    }

    return \@ret;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
