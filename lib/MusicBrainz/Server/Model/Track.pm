package MusicBrainz::Server::Model::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use MusicBrainz::Server::Adapter 'LoadEntity';

sub edit_number
{
    my ($self, $track, $new_number, $edit_note) = @_;

    if ($new_number ne $track->sequence)
    {
        $self->context->model('Moderation')->insert(
	    $edit_note,

	    type => ModDefs::MOD_EDIT_TRACKNUM,

	    newseq => $new_number,
	    track  => $track
	);
    }
}

sub edit_title
{
    my ($self, $track, $new_title, $edit_note) = @_;

    if ($new_title ne $track->name)
    {
        $self->context->model('Moderation')->insert(
	    $edit_note,

	    type => ModDefs::MOD_EDIT_TRACKNAME,

	    newname => $new_title,
	    track   => $track
	);
    }
}

sub edit_duration
{
    my ($self, $track, $new_duration, $edit_note) = @_;

    if ($new_duration ne $track->length)
    {
        $self->context->model('Moderation')->insert(
	    $edit_note,

	    type => ModDefs::MOD_EDIT_TRACKTIME,

	    newlength => $new_duration,
	    track     => $track
	);
    }
}

sub remove_from_release
{
    my ($self, $track, $release, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
	$edit_note,

	type => ModDefs::MOD_REMOVE_TRACK,

	track => $track,
	album => $release,
    );
}

sub change_artist
{
    my ($self, $track, $new_artist, $edit_note) = @_;

    # Load the track artist fully
    $track->artist->LoadFromId;

    $self->context->model('Moderation')->insert(
	$edit_note,

	type => ModDefs::MOD_CHANGE_TRACK_ARTIST,

        track          => $track,
        oldartist      => $track->artist,
        artistname     => $new_artist->name,
        artistsortname => $new_artist->sort_name,
        artistid       => $new_artist->id,
    );
}

sub load
{
    my ($self, $mbid) = @_;

    my $track = MusicBrainz::Server::Track->new($self->dbh);
    $track = LoadEntity($track, $mbid);

    return $track;
}

sub load_from_release
{
    my ($self, $release) = @_;

    my @tracks = $release->LoadTracks;
    my $puid_counts = $release->LoadPUIDCount;

    return [ map
    {
        my $track = $_;
        $track->{puid_count} = $puid_counts->{ $track->id };

        $track->artist->LoadFromId;
        $track;
    } @tracks ];
}

sub add_non_album_track
{
    my ($self, $artist, $track, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_ADD_TRACK_KV,

        artist      => $artist,
        trackname   => $track->name,
        tracklength => $track->length || 0,
    );
}

1;
