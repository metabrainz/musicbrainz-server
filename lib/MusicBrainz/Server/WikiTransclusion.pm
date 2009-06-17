#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

package MusicBrainz::Server::WikiTransclusion;

{ our @ISA = qw( Exporter ) }

use strict;
use Carp qw( cluck croak );
use Encode qw( encode decode );
use DBDefs;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Replication ':replication_type';
use LWP::Simple;

use constant WIKIDOCS_INDEX => "wikidocs-index";
use constant CACHE_INTERVAL => 60 * 60;

sub new
{
	my $class = shift;
    bless { }, ref($class) || $class;
}

sub GetPage
{
	return $_[0]->{page};
}

sub GetRevision
{
	return $_[0]->{revision};
}

sub SetPage
{
	$_[0]->{page} = $_[1];
}

sub SetRevision
{
	$_[0]->{revision} = $_[1];
}

sub ParseDocument
{
    my ($self, $data) = @_;

    my $index = { };
    foreach my $line (split(/\n/, $data))
    {
        my ($doc, $rev) = split(/=/, $line);

        $index->{$doc} = $rev;
    }
    return $index;
}

sub LoadIndexFromDisk
{
    my ($self) = @_;

    if (!open(FH, &DBDefs::WIKITRANS_INDEX_FILE))
    {
        print STDERR "ERROR: Could not open wikitrans index file: $!.\n";
        # oops, we blew it for this user -- the file is locked
        return undef;
    }

    undef $/;
    my $data = <FH>;
    close FH;

    return $self->ParseDocument($data);
}

sub LoadIndexFromMaster
{
    my ($self) = @_;

    my $data = get(&DBDefs::WIKITRANS_INDEX_URL);
    return undef if (!defined $data);
    return $self->ParseDocument($data);
}

sub GetPageIndex
{
    my $self = shift;
    my $index;

    # Get index from cache, if we have it
    if (!($index = MusicBrainz::Server::Cache->get(WIKIDOCS_INDEX)))
    {
        if (&DBDefs::REPLICATION_TYPE == RT_SLAVE)
        {
            $index = $self->LoadIndexFromMaster;
        }
        else
        {
            $index = $self->LoadIndexFromDisk;
        }
        return undef unless $index;
    }

    MusicBrainz::Server::Cache->set(WIKIDOCS_INDEX, $index);
    return $index;
}

sub Update
{
	my $self = shift;

    return 0 if (!defined($self->{page}) || !defined($self->{revision}));

    my $index = $self->GetPageIndex;
    return 0 if (!defined $index);

    $index->{$self->{page}} = $self->{revision};
    return $self->SaveIndex($index);
}

sub Delete
{
	my $self = shift;

    return undef if !defined($self->{page});

    my $index = $self->GetPageIndex;
    return 0 if (!defined $index);

    delete($index->{$self->{page}});
    return $self->SaveIndex($index);
}

sub SaveIndex
{
	my ($self, $index) = @_;

    return undef if !defined($self->{page} || &DBDefs::REPLICATION_TYPE == RT_SLAVE);

    MusicBrainz::Server::Cache->set(WIKIDOCS_INDEX, $index);

    # Write it to disk
    if (!open(FH, ">" . &DBDefs::WIKITRANS_INDEX_FILE))
    {
        print STDERR "ERROR: Could not open wikitrans index file for writing.\n";
        # oops, we blew it for this user -- the file is locked
        return undef;
    }

    foreach my $k (keys %$index)
    {
        print FH "$k=".$index->{$k}."\n";
    }
    close FH;

    # New remove each page from the cache
    foreach my $k (keys %$index)
    {
        MusicBrainz::Server::Cache->delete("wikidocs-$k");
    }

	return 1;
}

1;
# eof WikiTransclusion.pm
