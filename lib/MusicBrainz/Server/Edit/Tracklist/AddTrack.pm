package MusicBrainz::Server::Edit::Tracklist::AddTrack;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_ADDTRACK );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw( load_artist_credit_definitions artist_credit_from_loaded_definition );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Add track' }
sub edit_type { $EDIT_TRACKLIST_ADDTRACK }

sub alter_edit_pending { { Track => [ shift->track_id ] } }

sub related_entities
{
    my ($self) = @_;
    my $recording = $c->model('Recording')->get_by_id($self->data->{recording_id});
    my @releases = $c->model('Release')->find_by_tracklist($self->data->{tracklist_id});
    push @releases, $c->model('Release')->find_by_recording($recording->id);

    $self->c->model('ReleaseGroup')->load(@releases);
    $self->c->model('ArtistCredit')->load(@releases, $recording,
        map { $_->release_group } @releases);
 
    return {
        artist => [
            map { $_->artist_id } map { @{ $_->artist_credit->names } }
                $release, $release->release_group
        ],
        release => [ map { $_->id } @releases ],
        release_group => [ map { $_->release_group->id } @releases ]
        recording => [ $recording->id ],
    }
}

has 'track_id' => (
    isa => 'Int',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        tracklist_id => Int,
        position => Int,
        name => Str,
        recording_id => Nullable[Int],
        artist_credit => ArtistCreditDefinition,
        length => Nullable[Int],
    ],
);

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { $self->data->{recording_id} => [] },
        Artist => { load_artist_credit_definitions($self->data->{artist_credit}) }
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        name => $self->data->{name},
        length => $self->data->{length},
        tracklist_id => $self->data->{tracklist_id},
        artist => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        recording => $loaded->{Recording}->{ $self->data->{recording_id} }
    };
}

sub insert
{
    my $self = shift;

    $self->c->model('Tracklist')->offset_track_positions($self->data->{tracklist_id},
        $self->data->{position}, 1);

    my %data = %{ $self->data };
    $data{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $data{artist_credit} });

    if(!defined $data{recording_id}) {
        my $rec_data = {
            artist_credit => $data{artist_credit},
            name => $data{name},
            length => $data{length},
        };
        $data{recording_id} = $self->c->model('Recording')->insert($rec_data)->id;
    }

    my $track = $self->c->model('Track')->insert(\%data);
    $self->track_id($track->id);
}

sub reject
{
    my $self = shift;
    my $track = $self->c->model('Track')->get_by_id($self->track_id);
    $self->c->model('Track')->delete($track->id);
    $self->c->model('Tracklist')->offset_track_positions($self->data->{tracklist_id},
        $track->position, -1);
}

# track_id is handled separately, as it should not be copied if the edit is cloned
# (a new different track_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{track_id} = $self->track_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->track_id(delete $hash->{track_id});
};

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
