package MusicBrainz::Server::Entity::CDStub;

use Moose;
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Types qw( DateTime );

use namespace::autoclean;

extends 'MusicBrainz::Server::Entity';

sub entity_type { 'cdstub' }

has 'discid' => (
    is => 'rw',
    isa => 'Str'
);

has 'track_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'leadout_offset' => (
    is => 'rw',
    isa => 'Int'
);

has 'track_offset' => (
    is => 'rw',
    isa => 'ArrayRef[Int]'
);

has 'title' => (
    is => 'rw',
    isa => 'Str'
);

has 'artist' => (
    is => 'rw',
    isa => 'Str'
);

has 'date_added' => (
    is => 'rw',
    isa => DateTime,
    coerce => 1
);

has 'last_modified' => (
    is => 'rw',
    isa => DateTime,
    coerce => 1
);

has 'lookup_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'modify_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'source' => (
    is => 'rw',
    isa => 'Int'
);

has 'barcode' => (
    is => 'rw',
    isa => 'Barcode',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::Barcode->new() },
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'tracks' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::CDStubTrack]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_tracks => 'elements',
        add_track => 'push',
        clear_tracks => 'clear'
    }
);

with 'MusicBrainz::Server::Entity::Role::TOC';

sub length {
    my $self = shift;

    return int(($self->leadout_offset / 75) * 1000);
}

# XXX This should be called automatically when loading tracks
sub update_track_lengths {
    my $self = shift;
    my $index = 0;
    my @offsets = @{$self->track_offset};
    push @offsets, $self->leadout_offset;
    foreach my $track (@{$self->tracks}) {
        $track->length(int((($offsets[$index + 1] - $offsets[$index]) / 75) * 1000));
        $index++;
    }
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{artist} = $self->artist;
    $json->{barcode} = $self->barcode->format;
    $json->{comment} = $self->comment;
    $json->{date_added} = datetime_to_iso8601($self->date_added);
    $json->{discid} = $self->discid;
    $json->{last_modified} = datetime_to_iso8601($self->last_modified);
    $json->{leadout_offset} = $self->leadout_offset
        ? 0 + $self->leadout_offset
        : undef;
    $json->{lookup_count} = $self->lookup_count;
    $json->{modify_count} = $self->modify_count;
    $json->{title} = $self->title;
    $json->{toc} = $self->track_offset ? $self->toc : undef;
    $json->{track_count} = $self->track_count;
    $json->{track_offset} = $self->track_offset
        ? [map { 0 + $_ } @{ $self->track_offset }]
        : undef;
    $json->{tracks} = to_json_array($self->tracks);

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
