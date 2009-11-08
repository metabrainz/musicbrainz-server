package MusicBrainz::Server::Edit::Tracklist::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_CREATE );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_TRACKLIST_CREATE }
sub edit_name { "Create tracklist" }

sub models { [qw( Tracklist )] }

has 'tracklist_id' => (
    isa => 'Int',
    is  => 'rw'
);

has 'tracklist' => (
    isa => 'Tracklist',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        tracks => ArrayRef[
            Dict[
                name => Str,
                length => Nullable[Int],
                artist_credit => ArtistCreditDefinition,
                position => Int,
            ]
        ]
    ]
);

sub insert
{
    my $self = shift;
    my @tracks = @{ $self->data->{tracks} };

    for my $track (@tracks) {
        $track->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $track->{artist_credit} });
        if(!defined $track->{recording_id}) {
            my $rec_data = {
                artist_credit => $track->{artist_credit},
                name => $track->{name},
                length => $track->{length},
            };
            $track->{recording_id} = $self->c->model('Recording')->insert($rec_data)->id;
        }
    }

    my $tl = $self->c->model('Tracklist')->insert(\@tracks);
    $self->tracklist_id($tl->id);
}

sub reject
{
    my $self = shift;
    $self->c->model('Tracklist')->delete($self->tracklist_id);
}

# tracklist_id is handled separately, as it should not be copied if the edit is cloned
# (a new different tracklist_id would be used)
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{tracklist_id} = $self->tracklist_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->tracklist_id(delete $hash->{tracklist_id});
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
