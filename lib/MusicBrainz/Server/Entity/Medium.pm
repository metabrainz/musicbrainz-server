package MusicBrainz::Server::Entity::Medium;
use Moose;

use List::AllUtils qw( any sum );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'medium' }

has 'position' => (
    is => 'rw',
    isa => 'Int'
);

has 'track_count' => (
    is => 'rw',
    isa => 'Int',
);

has 'tracks' => (
    is => 'rw',
    isa => 'ArrayRef[Track]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_tracks => 'elements',
        add_track => 'push',
        clear_tracks => 'clear',
    }
);

has 'tracks_pager' => (
    is => 'rw',
    isa => 'Data::Page',
);

has has_loaded_tracks => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'release_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'release' => (
    is => 'rw',
    isa => 'Release'
);

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'format_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'format' => (
    is => 'rw',
    isa => 'Maybe[MediumFormat]',
);

sub format_name
{
    my ($self) = @_;
    return $self->format ? $self->format->name : undef;
}

sub l_format_name
{
    my ($self) = @_;
    return $self->format ? $self->format->l_name : undef;
}

has 'cdtocs' => (
    is => 'rw',
    isa => 'ArrayRef[MediumCDTOC]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_cdtocs => 'elements',
        add_cdtoc => 'push'
    }
);

sub may_have_discids {
    my $self = shift;
    return !$self->format || $self->format->has_discids;
}


=head2 length

Returns the duration of the medium in microseconds, including
possible pregap and data tracks.
If we have some tracks for which we are missing the durations,
returns undefined (since we don't actually know the true
duration of the medium).

=cut

sub length {
    my $self = shift;

    my @track_times = (
        @{ $self->pregap_length // [] },
        @{ $self->cdtoc_track_lengths // [] },
        @{ $self->data_track_lengths // [] },
    );

    return undef if any { !defined $_ } @track_times;

    return sum @track_times;
}

has 'has_pregap' => (
    is => 'rw',
    isa => 'Bool',
);

# If the medium has pregap/data tracks, they're excluded from this count.
has 'cdtoc_track_count' => (
    is => 'rw',
    isa => 'Int',
);

has 'cdtoc_track_lengths' => (
    is => 'rw',
    isa => 'Maybe[ArrayRef[Maybe[Int]]]'
);

has 'data_track_lengths' => (
    is => 'rw',
    isa => 'Maybe[ArrayRef[Maybe[Int]]]'
);

has 'pregap_length' => (
    is => 'rw',
    isa => 'Maybe[ArrayRef[Maybe[Int]]]'
);

has 'durations_loaded' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

sub audio_tracks {
    my ($self) = @_;
    return [ grep { !$_->is_data_track } $self->all_tracks ];
}

sub data_tracks {
    my ($self) = @_;
    return [ grep { $_->is_data_track } $self->all_tracks ];
}

sub cdtoc_tracks {
    my ($self) = @_;
    return [ grep { $_->position > 0 && !$_->is_data_track } $self->all_tracks ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $track_count = $self->track_count;

    my $data = {
        %{ $self->$orig },
        cdtocs      => [map { $_->cdtoc->toc } $self->all_cdtocs],
        format      => $self->format ? $self->format->TO_JSON : undef,
        format_id   => $self->format_id,
        name        => $self->name,
        position    => $self->position,
        release_id  => $self->release_id,
        track_count => defined $track_count ? (0 + $track_count) : undef,
    };

    if ($self->all_tracks) {
        $data->{tracks} = to_json_array($self->tracks);
    }

    if ($self->tracks_pager) {
        $data->{tracks_pager} = serialize_pager($self->tracks_pager);
    }

    if ($self->release) {
        $self->link_entity('release', $self->release->id, $self->release);
    }

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
