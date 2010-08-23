package MusicBrainz::Server::Controller::ReleaseEditor;
use Moose;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::Entity::TrackChangesPreview';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use MusicBrainz::Server::Data::Search;

BEGIN { extends 'MusicBrainz::Server::Controller' }

sub artist_compare
{
    my ($c, $old, $new) = @_;

    my $i = 0;
    for (@{ $old->names })
    {
        return 1 unless $new->names->[$i];
        return 1 if $_->name ne $new->names->[$i]->name ||
            $_->join_phrase  ne $new->names->[$i]->join_phrase ||
            $_->artist_id    != $new->names->[$i]->artist_id;

        $i++;
    }

    return 1 if $new->names->[$i];

    return 0;
}

sub search_result
{
    my ($c, $recording) = @_;

    my @extra;

    my ($tracks, $hits) = $c->model('Track')->find_by_recording ($recording->id, 10, 0);

    for (@{ $tracks })
    {
        my $release = $_->tracklist->medium->release;
        $release->mediums ([ $_->tracklist->medium ]);
        $release->mediums->[0]->tracklist ($_->tracklist);
        $release->mediums->[0]->tracklist->tracks ([ $_ ]);

        push @extra, $release;
    }

    $c->model('ArtistCredit')->load ($recording);

    return SearchResult->new ({ 
        entity => $recording,
        position => 1,
        score => 100,
        extra => \@extra,
    });
}

sub recording_suggestions
{
    my ($c, $changes, @prepend) = @_;

    my $query = MusicBrainz::Server::Data::Search::escape_query ($changes->track->name);
    my $artist = MusicBrainz::Server::Data::Search::escape_query ($changes->track->artist_credit->name);
    my $limit = 10;

    # FIXME: can we include track length too?  Might be useful in some searches... --warp.
    my $response = $c->model ('Search')->external_search (
        $c, 'recording', "$query artist:\"$artist\"", $limit, 1, 1);

    my @results;
    @results = @{ $response->{results} } if $response->{results};

    $changes->suggestions ([ @prepend, @results ]);
}

sub track_add
{
    my ($c, $newdata) = @_;

    delete $newdata->{id};

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});
    my $new = Track->new($newdata);
    
    my $t = TrackChangesPreview->new (added => 1, track => $new);

    recording_suggestions ($c, $t);

    return $t;
}

sub track_compare
{
    my ($c, $newdata, $old) = @_;

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});

    my $new = Track->new($newdata);
    my $preview = TrackChangesPreview->new (track => $new, old => $old);

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
        @suggest = ( search_result ($c, $old->recording) );
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
    my ($c, $new_medium, $old_medium) = @_;

    my @new;
    my @old;

    # first, only check moves/deletes.
    @new = @{ $new_medium->{tracklist}->{tracks} };
    @old = @{ $old_medium->tracklist->tracks } if $old_medium;

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
        push @ret, track_compare ($c, shift @new, shift @old);
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
    my ($c, $data, $release) = @_;

    my @old_media;
    my @new_media;

    @old_media = @{ $release->mediums } if $release;
    @new_media = @{ $data->{mediums} };

    if (scalar @old_media > scalar @new_media)
    {
        die ("removing discs is not yet supported.\n");
    }

    my @ret;
    while (@old_media)
    {
        push @ret, tracklist_compare ($c, shift @new_media, shift @old_media);
    }

    while (@new_media)
    {
        push @ret, tracklist_compare ($c, shift @new_media);
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
