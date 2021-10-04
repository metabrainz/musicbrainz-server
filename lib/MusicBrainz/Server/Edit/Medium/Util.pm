package MusicBrainz::Server::Edit::Medium::Util;

use strict;
use warnings;

use Clone qw(clone);
use List::AllUtils qw( all any uniq );
use MooseX::Types::Moose qw( Str Int Bool );
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
use aliased 'MusicBrainz::Server::Entity::Track';

use Sub::Exporter -setup => { exports => [qw(
    check_track_hash
    display_tracklist
    filter_subsecond_differences
    track
    tracks_to_hash
    tracklist_foreign_keys
)]};


sub filter_subsecond_differences
{
    my $tracks = shift;

    return [ map {
        my $trk = clone($_);
        $trk->{length} = unformat_track_length(format_track_length($trk->{length}));
        $trk;
    } @$tracks ];
}

sub tracks_to_hash
{
    my $tracks = shift;

    my $tmp = [ map +{
        id => $_->id,
        name => $_->name,
        artist_credit => artist_credit_to_ref($_->artist_credit),
        recording_id => $_->recording_id,
        position => $_->position,
        number => $_->number,
        length => $_->length,
        is_data_track => $_->is_data_track,
    }, @$tracks ];

    return $tmp;
}

sub check_track_hash {
    my $tracks = shift;

    my @track_ids = grep { defined $_ } map { $_->{id} } @$tracks;
    die 'Track IDs are not unique (MBS-7303)'
        unless scalar @track_ids == scalar uniq @track_ids;

    my @track_pos = sort { $a <=> $b } map { $_->{position} } @$tracks;
    die 'No tracks' unless @track_pos;
    die 'Track positions not given for all tracks'
        unless all { defined $_ } @track_pos;
    die 'Track positions are not unique (MBS-7721)'
        unless scalar @track_pos == scalar uniq @track_pos;
    die 'Track positions are non-contiguous (MBS-7846)'
        unless ($track_pos[0] == 0 || $track_pos[0] == 1)
            && scalar @track_pos == $track_pos[-1] - $track_pos[0] + 1;
}

sub tracklist_foreign_keys {
    my ($fk, $tracklist) = @_;

    $fk->{Artist} = {
        map {
            load_artist_credit_definitions($_->{artist_credit})
        } @$tracklist
    };

    $fk->{Recording} = {
        map { $_ => [ 'ArtistCredit' ] }
            grep { defined }
                map { $_->{recording_id } } @$tracklist
    };
}

sub track {
    return Dict[
        id => Nullable[Int],
        name => Str,
        artist_credit => ArtistCreditDefinition,
        length => Nullable[Int],
        recording_id => NullableOnPreview[Int],
        position => Int,
        number => Nullable[Str],
        is_data_track => Optional[Bool]
    ];
}

sub display_tracklist {
    my ($loaded, $tracklist) = @_;
    $tracklist ||= [];

    return [ map {
            Track->new(
                name => $_->{name},
                length => $_->{length},
                artist_credit => artist_credit_preview($loaded, $_->{artist_credit}),
                position => $_->{position},
                number => $_->{number} // $_->{position},
                is_data_track => $_->{is_data_track},
                recording => !$_->{recording_id} || !$loaded->{Recording}{ $_->{recording_id} } ?
                    Recording->new( name => $_->{name} ) :
                    $loaded->{Recording}{ $_->{recording_id} },
                defined($_->{recording_id}) ?
                    (recording_id => $_->{recording_id}) : (),
                defined($_->{id}) ?
                    (id => $_->{id}) : ()
            )
    } sort { $a->{position} <=> $b->{position} } @$tracklist ];
}

1;
