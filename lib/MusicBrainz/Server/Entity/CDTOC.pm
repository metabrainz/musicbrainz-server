package MusicBrainz::Server::Entity::CDTOC;

use Moose;
use Digest::SHA qw(sha1_base64);
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

sub entity_type { 'cdtoc' }

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

    my $message = '';
    $message .= sprintf('%02X', $first_track);
    $message .= sprintf('%02X', $last_track);
    $message .= sprintf('%08X', $leadout_offset);
    $message .= sprintf('%08X', ($track_offsets[$_-1] || 0)) for 1 .. 99;

    my $discid = sha1_base64($message);
    $discid .= '='; # bring up to 28 characters, like the client
    $discid =~ tr[+/=][._-];

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

    sprintf '%08x', ((($n % 0xFF) << 24) | ($t << 8) | $tracks);
}

with 'MusicBrainz::Server::Entity::Role::TOC';

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{discid} = $self->discid;

    return $json;
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
