package MusicBrainz::Server::Entity::Medium;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Translation qw( l );

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

Attempt to return the duration of the medium in microseconds.  This
will return the length of the disc, by looking at the associated
discids or tracklists.

This will not load any data from the database, so make sure you load
either the associated tracklists + tracks, the MediumCDTOC +
CDTOC, or both.

=cut

sub length {
    my $self = shift;

    if (scalar $self->all_tracks > 0)
    {
        my $length = 0;

        for my $trk ($self->all_tracks)
        {
            return undef unless defined $trk->length;

            $length += $trk->length;
        }

        return $length;
    }
    elsif ($self->cdtocs->[0] && $self->cdtocs->[0]->cdtoc)
    {
        return $self->cdtocs->[0]->cdtoc->length;
    }
    else
    {
        return undef;
    }
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

# Converted to JavaScript at root/utility/mediumHasMultipleArtists.js
sub has_multiple_artists {
    my ($self) = @_;
    foreach my $track ($self->all_tracks) {
        return 1 if $track->artist_credit_id != $self->release->artist_credit_id;
    }
    return 0;
}

has 'combined_track_relationships' => (
    is => 'ro',
    builder => '_build_combined_track_relationships',
    lazy => 1
);

sub _build_combined_track_relationships {
    my ($self) = @_;

    my (%combined, %keyed_relationships, %seen_recordings);

    my $add_relationship = sub {
        my ($track, $relationship) = @_;

        return if $relationship->target_type eq 'url';

        my $key = join(
            "\0",
            $relationship->target->gid,
            $relationship->target_credit,
            $relationship->link_order,
            $relationship->extra_phrase_attributes,
            $relationship->link->formatted_date
        );

        # Doesn't matter which we store, as long as only the source differs.
        $keyed_relationships{$key} = $relationship;

        my $for_target_type = $combined{$relationship->target_type} //= {};
        my $for_phrase = $for_target_type->{$relationship->phrase} //= {};

        push @{ $for_phrase->{$key} //= [] }, $track;
    };

    for my $track ($self->all_tracks) {
        next if exists $seen_recordings{$track->recording_id};

        $seen_recordings{$track->recording_id} = 1;

        for my $relationship ($track->recording->all_relationships) {
            $add_relationship->($track, $relationship);

            my %seen_works;
            if ($relationship->link->type->entity1_type eq 'work') {
                next if $seen_works{$relationship->target->id};

                $seen_works{$relationship->target->id} = 1;

                for my $relationship ($relationship->target->all_relationships) {
                    $add_relationship->($track, $relationship);
                }
            }
        }
    }

    while (my ($target_type, $target_type_group) = each %combined) {
        my @sorted;

        while (my ($phrase, $phrase_group) = each %$target_type_group) {
            my @items;

            while (my ($key, $tracks) = each %$phrase_group) {
                push @items, {
                    relationship => $keyed_relationships{$key},
                    tracks => track_range(@$tracks),
                    track_count => scalar @$tracks
                };
            }

            push @sorted, {
                phrase => $phrase,
                items => [ sort { $a->{relationship} <=> $b->{relationship} } @items ]
            };
        }

        $combined{$target_type} = [ sort { lc $a->{phrase} cmp lc $b->{phrase} } @sorted ];
    }

    return \%combined;
}

sub track_range {
    my @tracks = @_;
    my $range = [shift @tracks];
    my @ranges = $range;

    for my $track (@tracks) {
        if ($track->position - $range->[-1]->position == 1) {
            $range->[1] = $track;
        } else {
            $range = [$track];
            push @ranges, $range;
        }
    }

    @ranges = map {
        @$_ == 1
            ? $_->[0]->number
            : l('{start_track}&#x2013;{end_track}',
                { start_track => $_->[0]->number, end_track => $_->[1]->number })
    } @ranges;

    my $output = pop @ranges;

    for (reverse @ranges) {
        $output = l('{commas_only_list_item}, {rest}', { commas_only_list_item => $_, rest => $output });
    }

    return $output;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $data = {
        %{ $self->$orig },
        cdtocs      => [map { $_->cdtoc->toc } $self->all_cdtocs],
        format      => $self->format ? $self->format->TO_JSON : undef,
        format_id   => $self->format_id,
        name        => $self->name,
        position    => $self->position,
        release_id  => $self->release_id,
    };

    if ($self->all_tracks) {
        $data->{tracks} = to_json_array($self->tracks);
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
