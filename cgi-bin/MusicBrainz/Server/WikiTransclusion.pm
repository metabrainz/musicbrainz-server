#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

use TableBase;
{ our @ISA = qw( TableBase Exporter ) }

use strict;
use Carp qw( cluck croak );
use Encode qw( encode decode );
use DBDefs;
use MusicBrainz::Server::Cache;

use constant WIKIDOCS_INDEX => "wikidocs-index";
use constant CACHE_INTERVAL => 10*60;

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	return $self;
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

# This function is probably not going to be called anymore
sub LoadFromName
{
	my $self = shift;

	my $sql = Sql->new($self->{DBH});

	my $row = $sql->SelectSingleRowArray(
		  "SELECT	id, page, revision "
		. "FROM		wiki_transclusion "
		. "WHERE	page = ?",
		$self->{page},
	) or return undef;

    print STDERR "Found transcluded page\n";

	$self->{id}				= $row->[0];
	$self->{page}		    = $row->[1];
	$self->{revision}			= $row->[2];

	return 1;
}

sub GetPageIndex
{
    my $self = shift;
    my $index;

    if ($index = MusicBrainz::Server::Cache->get(WIKIDOCS_INDEX))
    {
        return $index;
    }

    print STDERR "Reload page index\n";
	my $sql = Sql->new($self->{DBH});
	my $list = $sql->SelectListOfHashes(
		  "SELECT	id, page, revision FROM	wiki_transclusion ORDER BY page "
	) or return undef;

    $index = {};
    foreach my $item (@{$list})
    {
        $index->{$item->{'page'}} = $item->{'revision'};
    }

    MusicBrainz::Server::Cache->set(WIKIDOCS_INDEX, $index, CACHE_INTERVAL);

    return $index;
}

sub Add
{
	my $self = shift;

    return 0 if (!defined($self->{page}) || !defined($self->{revision}));

	my $sql = Sql->new($self->{DBH});
    $sql->AutoCommit();
	$sql->Do(
		"INSERT INTO wiki_transclusion (page, revision) values (?, ?)",
		$self->{page}, $self->{revision}
    ) or return 0;

    $self->ClearCache();

    1;
}

sub Update
{
	my $self = shift;

    return 0 if (!defined($self->{page}) || !defined($self->{revision}));

	my $sql = Sql->new($self->{DBH});
    $sql->AutoCommit();
	$sql->Do(
		"UPDATE wiki_transclusion SET revision = ? WHERE page = ?",
		$self->{revision}, $self->{page}
    ) or return 0;

    $self->ClearCache();

    1;
}

sub Delete
{
	my $self = shift;

    return undef if !defined($self->{page});

    # Clear out the cache BEFORE the delete, in case the index cache
    # entry is out of date and has to be refetched during the cache deletion
    $self->ClearCache();

	# Delete the data
	my $sql = Sql->new($self->{DBH});
    $sql->AutoCommit();
	$sql->Do(
		"DELETE FROM wiki_transclusion WHERE page = ?",
		$self->{page},
	);
}

sub ClearCache
{
	my $self = shift;

    return undef if !defined($self->{page});

    print STDERR "Clear cache\n";
    my $list = $self->GetPageIndex();
    foreach my $page (keys %$list)
    {
        MusicBrainz::Server::Cache->delete("wikidocs-".$page);
    }
    MusicBrainz::Server::Cache->delete(WIKIDOCS_INDEX);
}

1;
# eof WikiTransclusion.pm
