package MusicBrainz::Server::Entity::Release;
use Moose;

use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );

use MusicBrainz::Server::Entity::Util::MediumFormat qw( combined_medium_format_name );

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Quality';

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

has 'country_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'country' => (
    is => 'rw',
    isa => 'Country'
);

has 'date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
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

sub combined_track_count
{
    my ($self) = @_;
    my @mediums = @{$self->mediums};
    return "" if !@mediums;
    my @counts;
    foreach my $medium (@mediums) {
        push @counts, $medium->tracklist ? $medium->tracklist->track_count : 0;
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
        next unless $medium->tracklist;
        foreach my $track ($medium->tracklist->all_tracks) {
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
        for my $track ($medium->tracklist->all_tracks) {
            next unless defined $track->recording;
            return $medium if $track->recording->gid eq $recording->gid;
        }
    }
}

sub find_track_for_recording {
    my ($self, $recording) = @_;
    my $medium = $self->find_medium_for_recording($recording) or return;
    for my $track ($medium->tracklist->all_tracks) {
        next unless defined $track->recording;
        return $track if $track->recording->gid eq $recording->gid;
    }
}

sub all_tracks
{
    my $self = shift;
    my @mediums = $self->all_mediums
        or return ();
    my @tracklists = grep { defined } map { $_->tracklist } @mediums
        or return ();
    return map { $_->all_tracks } @tracklists;
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
