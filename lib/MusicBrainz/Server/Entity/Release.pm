package MusicBrainz::Server::Entity::Release;
use Moose;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );

use MusicBrainz::Server::Entity::Util::MediumFormat qw( combined_medium_format_name );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Quality';

use aliased 'MusicBrainz::Server::Entity::Work';

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    if ($args->{barcode} && !ref($args->{barcode})) {
        $args->{barcode} = MusicBrainz::Server::Entity::Barcode->new( $args->{barcode} );
    }

    return $args;
};

has 'status_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'status' => (
    is => 'rw',
    isa => 'ReleaseStatus'
);

sub status_name
{
    my ($self) = @_;
    return $self->status ? $self->status->name : undef;
}

sub l_status_name
{
    my ($self) = @_;
    return $self->status ? $self->status->l_name : undef;
}

has 'packaging_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'packaging' => (
    is => 'rw',
    isa => 'ReleasePackaging'
);

sub packaging_name
{
    my ($self) = @_;
    return $self->packaging ? $self->packaging->name : undef;
}

sub l_packaging_name
{
    my ($self) = @_;
    return $self->packaging ? $self->packaging->l_name : undef;
}

has 'artist_credit_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'release_group' => (
    is => 'rw',
    isa => 'ReleaseGroup'
);

has 'release_group_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'artist_credit' => (
    is => 'rw',
    isa => 'ArtistCredit',
    predicate => 'artist_credit_loaded',
);

has 'barcode' => (
    is => 'rw',
    isa => 'Barcode',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::Barcode->new() },
);

has 'language_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'language' => (
    is => 'rw',
    isa => 'Language'
);

has 'script_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'script' => (
    is => 'rw',
    isa => 'Script'
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'labels' => (
    is => 'rw',
    isa => 'ArrayRef[ReleaseLabel]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_labels => 'elements',
        add_label => 'push',
        clear_labels => 'clear',
        label_count => 'count'
    }
);

has 'mediums' => (
    is => 'rw',
    isa => 'ArrayRef[Medium]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_mediums => 'elements',
        add_medium => 'push',
        clear_mediums => 'clear',
        medium_count => 'count'
    }
);

has events => (
    is => 'rw',
    isa => 'ArrayRef[ReleaseEvent]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_event => 'push',
        all_events => 'elements',
        event_count => 'count'
    }
);

sub combined_track_count
{
    my ($self) = @_;
    my @mediums = @{$self->mediums};
    return "" if !@mediums;
    my @counts;
    foreach my $medium (@mediums) {
        push @counts, $medium->track_count;
    }
    return join " + ", @counts;
}

sub combined_format_name
{
    my ($self) = @_;
    my @mediums = @{$self->mediums};
    return "" if !@mediums;
    return combined_medium_format_name(map { $_->l_format_name() || l('(unknown)') } @mediums );
}

sub has_multiple_artists
{
    my ($self) = @_;
    foreach my $medium ($self->all_mediums) {
        foreach my $track ($medium->all_tracks) {
            if ($track->artist_credit_id != $self->artist_credit_id) {
                return 1;
            }
        }
    }
    return 0;
}

has [qw( cover_art_url info_url amazon_asin amazon_store )] => (
    is => 'rw',
    isa => 'Str',
);

has 'cover_art' => (
    isa       => 'MusicBrainz::Server::CoverArt',
    is        => 'rw',
    predicate => 'has_cover_art',
);

has 'cover_art_presence' => (
    isa => 'Str',
    is => 'rw'
);

sub may_have_cover_art {
    return shift->cover_art_presence ne 'darkened';
}

sub find_medium_for_recording {
    my ($self, $recording) = @_;
    for my $medium ($self->all_mediums) {
        for my $track ($medium->all_tracks) {
            next unless defined $track->recording;
            return $medium if $track->recording->gid eq $recording->gid;
        }
    }
}

sub find_track_for_recording {
    my ($self, $recording) = @_;
    my $medium = $self->find_medium_for_recording($recording) or return;
    for my $track ($medium->all_tracks) {
        next unless defined $track->recording;
        return $track if $track->recording->gid eq $recording->gid;
    }
}

sub all_tracks
{
    my $self = shift;
    my @mediums = $self->all_mediums
        or return ();
    return map { $_->all_tracks } @mediums;
}

sub filter_labels
{
    my ($self, $label) = @_;
    my @labels = $self->all_labels
        or return ();
    return grep { $_->label_id && $_->label_id == $label->id } @labels;
}

=head2 length

Return the duration of the release in microseconds.
(or undef if the duration of one or more media is not known).

=cut

sub length {
    my $self = shift;

    my $length = 0;

    for my $disc ($self->all_mediums)
    {
        my $l = $disc->length;
        return undef unless $l;

        $length += $l;
    }

    return $length;
}

sub combined_track_relationships {
    my ($self) = @_;

    my $combined_rels = {};
    my %track_numbers = ();
    my $show_medium_prefix = 0;

    my $find_dup_rel = sub {
        my ($rel, $items) = @_;

        for my $item (@$items) {
            if ($rel->target == $item->{rel}->target &&
                    $rel->link->formatted_date eq
                    $item->{rel}->link->formatted_date) {
                return $item;
            }
        }
        # No match found
        my $item = { rel => $rel, tracks => [] };
        push @$items, $item;
        return $item;
    };

    # Group identical relationships, storing what tracks they appear on (or
    # whether they appear as a release relationship).
    my $merge_rels = sub {
        my ($source_rels, $track) = @_;

        for my $target_type (keys %$source_rels) {
            my $rels_by_phrase = $source_rels->{ $target_type };
            my $combined_by_phrase = $combined_rels->{ $target_type } //= {};

            for my $phrase (keys %$rels_by_phrase) {
                my $items = $combined_by_phrase->{ $phrase } //= [];

                for my $rel (@{ $rels_by_phrase->{ $phrase } }) {
                    my $item = $find_dup_rel->($rel, $items);

                    if (defined $track) {
                        push @{ $item->{tracks} }, $track;
                    } else {
                        $item->{release} = 1;
                    }
                }
            }
        }
    };

    my $medium_count = scalar $self->all_mediums;
    my $track_count = 0;
    my $abs_track_position = {};

    $merge_rels->($self->grouped_relationships);

    for my $medium ($self->all_mediums) {
        for my $track ($medium->all_tracks) {
            $track->medium($medium);
            $abs_track_position->{ $track->id } = ++$track_count;

            if (!$show_medium_prefix && $medium_count > 1 &&
                    exists $track_numbers{ $track->number }) {
                $show_medium_prefix = 1;
            } else {
                $track_numbers{ $track->number } = 1;
            }

            $merge_rels->($track->recording->grouped_relationships, $track);

            $merge_rels->($_->grouped_relationships('artist'), $track)
                for grep { $_->isa(Work) } map { $_->target }
                    $track->recording->all_relationships
        }
    }

    # Given a track, return its number. If there are *any* duplicate track
    # numbers on the release, prepend all track numbers with the medium
    # position to disambiguate them.
    my $track_number = sub {
        my ($track) = @_;
        return ($show_medium_prefix ?
            $track->medium->position . '.' : '') . $track->number;
    };

    # Convert a list of tracks to a string representation of the track numbers,
    # e.g. 1-3, 5-7.
    my $tracks_to_string = sub {
        my @tracks = @{ $_[0] };
        my $a = $tracks[0];
        my $result = $track_number->($a);

        for (my $i = 1; $i <= $#tracks; $i++) {
            my $b = $tracks[$i];
            my $apos = $abs_track_position->{ $a->id };
            my $bpos = $abs_track_position->{ $b->id };
            my $seq = $bpos - $apos == 1;

            if (!$seq || $i == $#tracks) {
                my ($anum, $bnum) = ($track_number->($a), $track_number->($b));

                my $endseq = ($i > 1 &&
                    $apos - $abs_track_position->{ $tracks[$i - 2]->id } == 1 ?
                    '&#x2013;' . $anum : '');

                $result .= ($seq ? '&#x2013;' . $bnum : $endseq . ', ' . $bnum);
            }
            $a = $b;
        }
        return $result;
    };

    for my $target_type (keys %$combined_rels) {
        my $rels_by_phrase = $combined_rels->{ $target_type };
        my @rel_phrases = sort { lc $a cmp lc $b } uniq keys %$rels_by_phrase;
        my @ordered_rels;

        for my $phrase (@rel_phrases) {
            my $items = $rels_by_phrase->{ $phrase };
            for my $item (@$items) {
                # Now that all tracks that the relationship appears on are
                # known, we no longer need them, only their string repr.
                $item->{track_count} = scalar @{ $item->{tracks} };

                if ($item->{track_count}) {
                    $item->{tracks} = $tracks_to_string->($item->{tracks});
                }
            }
            # Turn the
            #   { actual_phrase => \@actual_items }
            # structure into
            #   [ { phrase => $actual_phrase, items => \@actual_items } ]
            # so that relationships are pre-sorted by phrase case-insensitively
            # for the template.
            @$items = sort { $a->{rel} <=> $b->{rel} } @$items;
            push @ordered_rels, { phrase => $phrase, items => $items };
        }
        $combined_rels->{ $target_type } = \@ordered_rels;
    }

    return $combined_rels;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
