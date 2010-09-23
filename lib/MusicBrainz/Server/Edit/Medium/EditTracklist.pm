package MusicBrainz::Server::Edit::Medium::EditTracklist;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT_TRACKLIST );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Edit tracklist' }
sub edit_type { $EDIT_MEDIUM_EDIT_TRACKLIST }

sub track {
    return Dict[
        name => Str,
        artist_credit => ArtistCreditDefinition,
        length => Nullable[Int],
        recording_id => Int,
    ];
}

has '+data' => (
    isa => Dict[
        tracklist_id => Int,
        medium_id => Int,
        separate_tracklists => Bool,
        old_tracklist => ArrayRef[track()],
        new_tracklist => ArrayRef[track()]
    ]
);

sub medium_id { shift->data->{medium_id} }

sub initialize
{
    my ($self, %opts) = @_;
    $self->data({
        tracklist_id => $opts{tracklist_id},
        medium_id => $opts{medium_id},
        separate_tracklists => $opts{separate_tracklists},
        old_tracklist => [
            map +{
                artist_credit => artist_credit_to_ref($_->artist_credit),
                name => $_->name,
                length => $_->length,
                recording_id => $_->recording_id,
            }, $opts{old_tracklist}->all_tracks
        ],
        new_tracklist => $opts{new_tracklist}
    });
}

sub accept
{
    my $self = shift;

    # Make sure the medium still has the same tracklist
    my $medium = $self->c->model('Medium')->get_by_id($self->medium_id);
    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        "The medium's tracklist has been modified since the edit was created"
    ) if $medium->tracklist_id != $self->data->{tracklist_id};

    # Make sure the track count is the same
    $self->c->model('Tracklist')->load($medium);
    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        "The medium's tracklist has been modified since the edit was created"
    ) if $medium->tracklist->track_count != @{ $self->data->{old_tracklist} };

    # See if we need a new tracklist
    if ($self->data->{separate_tracklists} &&
        $self->c->model('Tracklist')->usage_count($medium->tracklist_id > 1)) {
         my $new_tracklist_id = $self->c->model('Tracklist')->insert(
            $self->data->{new_tracklist}
         );
         $self->c->model('Medium')->update($medium->id, {
            tracklist_id => $new_tracklist_id
         });
    }
    else {
        $self->c->model('Tracklist')->replace($medium->tracklist_id, 
            $self->data->{new_tracklist});
    }
}

__PACKAGE__->meta->make_immutable;
1;
