package MusicBrainz::Server::Entity::CDTOC;

use Moose;
use Digest::SHA qw(sha1_base64);
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has 'discid' => (
    is => 'rw',
    isa => 'Str'
);

has 'freedb_id' => (
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

has 'degraded' => (
    is => 'rw',
    isa => 'Boolean'
);

sub first_track
{
    return 1;
}

sub last_track
{
    my ($self) = @_;

    return $self->track_count;
}

sub sectors_to_ms
{
    return int($_[0] / 75 * 1000);
}

sub length
{
    my ($self) = @_;

    return sectors_to_ms($self->leadout_offset);
}

sub track_details
{
    my ($self) = @_;

    my @track_info;
    foreach my $track (0 .. ($self->track_count - 1)) {
        my %info;
        $info{start_sectors} = $self->track_offset->[$track];
        $info{start_time} = sectors_to_ms($info{start_sectors});
        $info{end_sectors} = ($track == $self->track_count - 1)
            ? $self->leadout_offset
            : $self->track_offset->[$track + 1];
        $info{end_time} = sectors_to_ms($info{end_sectors});
        $info{length_sectors} = $info{end_sectors} - $info{start_sectors};
        $info{length_time} = sectors_to_ms($info{length_sectors});
        push @track_info, \%info;
    }
    return \@track_info;
}

sub new_from_toc
{
    my ($class, $toc) = @_;
    return unless defined($toc);

    $toc =~ s/\A\s+//;
    $toc =~ s/\s+\z//;
    $toc =~ /\A\d+(?: \d+)*\z/ or return;

    my ($first_track, $last_track, $leadout_offset, @track_offsets) = split ' ', $toc;

    return unless $first_track == 1;
    return unless $last_track >= 1 && $last_track <= 99;
    return unless @track_offsets == $last_track;

    for (($first_track + 1) .. $last_track) {
      return unless $track_offsets[$_-1] > $track_offsets[$_-1-1];
    }

    return unless $leadout_offset > $track_offsets[-1];

    my $message = "";
    $message .= sprintf("%02X", $first_track);
    $message .= sprintf("%02X", $last_track);
    $message .= sprintf("%08X", $leadout_offset);
    $message .= sprintf("%08X", ($track_offsets[$_-1] || 0)) for 1 .. 99;

    my $discid = sha1_base64($message);
    $discid .= "="; # bring up to 28 characters, like the client
    $discid =~ tr[+/=][._-];

    my @lengths = map {
        ($track_offsets[$_+1-1] || $leadout_offset) - $track_offsets[$_-1]
    } $first_track .. $last_track;

    return $class->new(
        discid => $discid,
        track_count => scalar @track_offsets,
        leadout_offset => $leadout_offset,
        track_offset => \@track_offsets,
        freedb_id => _compute_freedb_id(@track_offsets, $leadout_offset),
    );
}

sub _compute_freedb_id
{
    my @frames = @_;
    my $tracks = @frames-1;

    my $n = 0;
    for my $i (0..$tracks-1) {
        $n = $n + $_
        for split //, int($frames[$i]/75);
    }

    my $t = int($frames[-1]/75) - int($frames[0]/75);

    sprintf "%08x", ((($n % 0xFF) << 24) | ($t << 8) | $tracks);
}

with 'MusicBrainz::Server::Entity::Role::TOC';

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
