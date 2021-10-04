#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::PagedReport;

use Storable qw( freeze thaw );
my $intlen = length(pack 'i', 0);

################################################################################
# Save
################################################################################

sub Save
{
    my ($class, $file) = @_;
    open(my $fh1, ">$file.dat") or die $!;
    open(my $fh2, ">$file.idx") or die $!;
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
        or die $!;
    print $idx pack 'i', $pos
        or die $!;

    ++$self->{NUM};
}

sub End
{
    close $_[0]{IDX} or die $!;
    close $_[0]{DAT} or die $!;
}

################################################################################
# Load
################################################################################

sub Load
{
    my ($class, $file) = @_;
    open(my $dat, "<$file.dat") or die $!;
    open(my $idx, "<$file.idx") or die $!;
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
        or die $!;

    if (eof $idx)
    {
        seek($dat, 0, 2)
                or die $!;
    } else {
        read($idx, my $idxpos, $intlen)
                or die $!;
        seek($dat, unpack('i', $idxpos), 0)
                or die $!;
    }

    $self->{CUR} = $pos;
}

sub Get
{
    my ($self, $pos) = @_;

    my $dat = $self->{DAT};
    my $idx = $self->{IDX};

    $self->Seek($pos) if defined $pos;

    return undef if eof $dat;

    read($dat, my $reclen, $intlen)
        or die $!;
    read($dat, my $record, unpack('i', $reclen))
        or die $!;
    ++$self->{CUR};

    thaw($record);
}

1;
# eof PagedReport.pm
