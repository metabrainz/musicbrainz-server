package MusicBrainz::Server::Edit::Medium::EditTracklist;
use Moose;
use namespace::autoclean;

use Data::Compare;
use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT_TRACKLIST );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw( artist_credit_from_loaded_definition );
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );

extends 'MusicBrainz::Server::Edit';

use aliased 'MusicBrainz::Server::Entity::Tracklist';
use aliased 'MusicBrainz::Server::Entity::Track';

sub edit_name { 'Edit tracklist' }
sub edit_type { $EDIT_MEDIUM_EDIT_TRACKLIST }

has 'mediums' => (
    isa => 'ArrayRef',
    lazy_build => 1,
    traits => [ 'Array' ],
    handles => {
        mediums => 'elements',
    }
);

sub _build_mediums {
    my $self = shift;

    my @mediums;
    if ($self->data->{separate_tracklists}) {
        @mediums = (
            $self->c->model('Medium')->get_by_id($self->data->{medium_id})
        );
    }
    else {
        @mediums = $self->c->model('Medium')->find_by_tracklist(
            $self->data->{tracklist_id}, 100, 0);
    }
    $self->c->model('Release')->load(@mediums);

    return \@mediums;
}

sub alter_edit_pending
{
    my $self = shift;

    return {
        Medium => [ map { $_->id } $self->mediums ],
        Release => [ map { $_->release_id } $self->mediums ]
    }
}

sub related_entities
{
    my $self = shift;
    return {
        release => [ map { $_->release_id } $self->mediums ],
        recording =>  [
            $self->recording_ids
        ],
        artist => [
            $self->artist_ids
        ],
        release_group => [
            map { $_->release->release_group_id } $self->mediums
        ]
    };
}

sub artist_ids
{
    my $self = shift;
    map { $_->{artist} }
        grep { ref($_) } map { @{ $_->{artist_credit} } }
        @{ $self->data->{new_tracklist} },
        @{ $self->data->{old_tracklist} }
}

sub recording_ids
{
    my $self = shift;
    map { $_->{recording_id} }
        @{ $self->data->{new_tracklist} },
        @{ $self->data->{old_tracklist} }
}

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

sub _tracks_to_hash
{
    my $tracks = shift;
    return [ map +{
        artist_credit => artist_credit_to_ref($_->artist_credit),
        name => $_->name,
        # Filter out sub-second differences
        length => unformat_track_length(format_track_length($_->length)),
        recording_id => $_->recording_id,
    }, @$tracks ];
}

sub initialize
{
    my ($self, %opts) = @_;
    my $data = {
        tracklist_id => $opts{tracklist_id},
        medium_id => $opts{medium_id},
        separate_tracklists => $opts{separate_tracklists},
        old_tracklist => _tracks_to_hash($opts{old_tracklist}->tracks),
        new_tracklist => _tracks_to_hash($opts{new_tracklist})
    };

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if Compare($data->{old_tracklist}, $data->{new_tracklist});

    $self->data($data);
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

    for my $track (@{ $self->data->{new_tracklist} }) {
        $track->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $track->{artist_credit} });
    }

    # See if we need a new tracklist
    if ($self->data->{separate_tracklists} &&
        $self->c->model('Tracklist')->usage_count($medium->tracklist_id) > 1) {
         my $new_tracklist = $self->c->model('Tracklist')->insert(
            $self->data->{new_tracklist}
         );
         $self->c->model('Medium')->update($medium->id, {
            tracklist_id => $new_tracklist->id
         });
    }
    else {
        $self->c->model('Tracklist')->replace($medium->tracklist_id, 
            $self->data->{new_tracklist});
    }
}

sub foreign_keys
{
    my ($self) = @_;
    return {
        Artist => [ $self->artist_ids ],
        Medium => {
            map {
                $_->id => [ 'Release', 'MediumFormat' ]
            } $self->mediums
        },
        Recording => [ $self->recording_ids ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        mediums => [
            map { $loaded->{Medium}{ $_->id } } $self->mediums
        ],
        old_tracklist => $self->create_tracklist(
            $self->data->{old_tracklist}, $loaded),
        new_tracklist => $self->create_tracklist(
            $self->data->{new_tracklist}, $loaded),
    }
}

sub create_tracklist
{
    my ($self, $tracklist, $loaded) = @_;
    my $i = 1;
    return Tracklist->new(
        tracks => [
            map {
                Track->new(
                    name => $_->{name},
                    artist_credit => artist_credit_from_loaded_definition($loaded, $_->{artist_credit}),
                    length => $_->{length},
                    recording => $loaded->{Recording}{$_->{recording_id}},
                    position => $i++,
                )
            } @$tracklist
        ]
    );
}

__PACKAGE__->meta->make_immutable;
1;
