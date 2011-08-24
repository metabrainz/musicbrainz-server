package MusicBrainz::Server::Report::TracksNamedWithSequence;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report';

sub gather_data {
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, <<'EOSQL');
SELECT DISTINCT
  tname.name,
  track.artist_credit AS artist_credit,
  rname.name AS rec_name,
  recording.gid AS rec_gid,
  musicbrainz_collate(tname.name)
FROM track
JOIN recording ON track.recording = recording.id
JOIN track_name tname ON tname.id = track.name
JOIN track_name rname ON rname.id = recording.name
WHERE tname.name ~ '^[0-9]'
AND   tname.name ~ ('^0*' || track.position || '[^0-9]')
ORDER BY musicbrainz_collate(tname.name)
EOSQL
}

sub template { 'report/tracks_named_with_sequence.tt' }

sub post_load {
    my ($self, $items) = @_;
    for my $item (@$items) {
        $item->{track} = $self->c->model('Track')->_new_from_row($item);
        $item->{track}->recording(
            $self->c->model('Recording')->_new_from_row($item, 'rec_')
        );
    }

    $self->c->model('ArtistCredit')->load(map { $_->{track} } @$items);
}

1;
