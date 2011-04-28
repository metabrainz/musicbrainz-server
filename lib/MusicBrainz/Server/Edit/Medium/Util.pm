package MusicBrainz::Server::Edit::Medium::Util;

use strict;
use warnings;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    NullableOnPreview
);
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_preview
);
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::Tracklist';
use aliased 'MusicBrainz::Server::Entity::Track';

use Sub::Exporter -setup => {
    exports => [qw( tracks_to_hash tracklist_foreign_keys track display_tracklist )],
};

sub tracks_to_hash
{
    my $tracks = shift;
    return [ map +{
        name => $_->name,
        artist_credit => artist_credit_to_ref ($_->artist_credit),
        recording_id => $_->recording_id,
        position => $_->position,

        # Filter out sub-second differences
        length => unformat_track_length(format_track_length($_->length)),
    }, @$tracks ];
}

sub tracklist_foreign_keys {
    my ($fk, $tracklist) = @_;

    $fk->{Artist} = {
        map {
            load_artist_credit_definitions($_->{artist_credit})
        } @$tracklist
    };

    $fk->{Recording} = [
        map {
            $_->{recording_id}
        } @$tracklist
    ];
}

sub track {
    return Dict[
        name => Str,
        artist_credit => ArtistCreditDefinition,
        length => Nullable[Int],
        recording_id => NullableOnPreview[Int],
        position => Int,
    ];
}

sub display_tracklist {
    my ($loaded, $tracklist) = @_;
    $tracklist ||= [];
    return unless @$tracklist;

    return Tracklist->new(
        tracks => [ map {
            Track->new(
                name => $_->{name},
                length => $_->{length},
                artist_credit => artist_credit_preview ($loaded, $_->{artist_credit}),
                position => $_->{position},
                recording => !$_->{recording_id} || !$loaded->{Recording}{ $_->{recording_id} } ?
                    Recording->new( name => $_->{name} ) : 
                    $loaded->{Recording}{ $_->{recording_id} }
            )
        } sort { $a->{position} <=> $b->{position} } @$tracklist ]
    )
}

1;
