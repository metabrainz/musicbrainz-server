package MusicBrainz::Server::Edit::Track::Edit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use Moose::Util::TypeConstraints qw( as find_type_constraint subtype );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Constants qw( $EDIT_TRACK_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Edit track' }
sub edit_type { $EDIT_TRACK_EDIT }

sub alter_edit_pending { { Track => [ shift->track_id ] } }
sub models { [qw( Track )] }

has 'track_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{track} }
);

has 'track' => (
    isa => 'Track',
    is => 'rw',
);

subtype 'TrackHash',
    as Dict[
        name => Optional[Str],
        recording_id => Optional[Int],
        tracklist_id => Optional[Int],
        artist_credit => Optional[ArtistCreditDefinition],
    ];

has '+data' => (
    isa => Dict[
        track => Int,
        old => find_type_constraint('TrackHash'),
        new => find_type_constraint('TrackHash')
    ]
);

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) }
    );
}

sub initialize
{
    my ($self, %opts) = @_;
    my $track = delete $opts{track}
        or die 'Must specify the track object to edit';

    if (!defined $track->artist_credit) {
        $self->c->model('ArtistCredit')->load($track);
    }

    $self->track_id($track->id);
    $self->track($track);
    $self->data({
        track => $track->id,
        old => $self->_change_hash($track, keys %opts),
        new => { %opts },
    });
}

sub accept
{
    my ($self) = @_;
    my %data = %{ $self->data->{new} };

    my $ac = $self->c->model('ArtistCredit')->find_or_insert(@{ $data{artist_credit} });
    $data{artist_credit} = $ac;

    $self->c->model('Track')->update($self->track_id, \%data);
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
__PACKAGE__->register_type;
no Moose;

1;
