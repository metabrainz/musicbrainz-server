#!/usr/bin/env perl

use warnings;
use strict;

package MusicBrainz::Server::PagedReport;

use English;
use Storable qw( freeze thaw );
my $intlen = length(pack 'i', 0);

################################################################################
# Save
################################################################################

sub Save
{
    my ($class, $file) = @_;
    open(my $fh1, ">$file.dat") or die $OS_ERROR;
    open(my $fh2, ">$file.idx") or die $OS_ERROR;
    binmode $fh1;
    binmode $fh2;
    bless {
        NUM     => 0,
        DAT     => $fh1,
        IDX     => $fh2,
    }, ref($class) || $class;
}

sub Print
{
    my ($self, $record) = @_;
    $record = freeze($record);

    my $dat = $self->{DAT};
    my $idx = $self->{IDX};

    my $pos = tell $dat;
    die if $pos < 0;
    print $dat pack('i', length($record)), $record
        or die $OS_ERROR;
    print $idx pack 'i', $pos
        or die $OS_ERROR;

    ++$self->{NUM};
}

sub End
{
    close $_[0]{IDX} or die $OS_ERROR;
    close $_[0]{DAT} or die $OS_ERROR;
}

################################################################################
# Load
################################################################################

sub Load
{
    my ($class, $file) = @_;
    open(my $dat, "<$file.dat") or die $OS_ERROR;
    open(my $idx, "<$file.idx") or die $OS_ERROR;
    binmode $dat;
    binmode $idx;
    bless {
        NUM     => ((-s $idx) / $intlen),
        CUR     => 0,
        DAT     => $dat,
        IDX     => $idx,
    }, ref($class) || $class;
}

sub Time { (stat $_[0]{IDX})[9] }
sub Records { $_[0]{NUM} }
sub Position { $_[0]{CUR} }

sub Seek
{
    my ($self, $pos) = @_;

    $pos = int $pos;
    $pos = $self->Records if $pos > $self->Records;

    my $dat = $self->{DAT};
    my $idx = $self->{IDX};

    seek($idx, $pos * $intlen, 0)
        or die $OS_ERROR;

    if (eof $idx)
    {
        seek($dat, 0, 2)
                or die $OS_ERROR;
    } else {
        read($idx, my $idxpos, $intlen)
                or die $OS_ERROR;
        seek($dat, unpack('i', $idxpos), 0)
                or die $OS_ERROR;
    }

    $self->{CUR} = $pos;
}

sub Get
{
    my ($self, $pos) = @_;

    my $dat = $self->{DAT};

    $self->Seek($pos) if defined $pos;

    return undef if eof $dat;

    read($dat, my $reclen, $intlen)
        or die $OS_ERROR;
    read($dat, my $record, unpack('i', $reclen))
        or die $OS_ERROR;
    ++$self->{CUR};

    thaw($record);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
