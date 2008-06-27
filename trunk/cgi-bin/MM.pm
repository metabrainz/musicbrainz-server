#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the internet music database
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

package MM;

use ModDefs qw( VARTIST_ID );

use TableBase;
use RDF2;
{ our @ISA = qw( TableBase RDF2 ) }

use strict;
use DBDefs;

sub SetBaseURI
{
    my ($this, $uri) = @_;

    $this->{baseuri} = $uri;
}

sub GetBaseURI
{
    return $_[0]->{baseuri};
}

sub SetDepth
{
    my ($this, $depth) = @_;

    $this->{depth} = $depth;
}

sub GetDepth
{
    return $_[0]->{depth};
}

sub SetOutputFile
{
    $_[0]->{file} = $_[1];
}

sub ErrorRDF
{
    my ($this, @text) = @_;
    my ($rdf);

    $rdf = $this->BeginRDFObject;
    $rdf .= $this->BeginDesc("mq:Result");
    $rdf .= $this->Element("mq:error", "@text");
    $rdf .= $this->EndDesc("mq:Result");
    $rdf .= $this->EndRDFObject;

    return $rdf;
}

sub CreateStatus
{
    my ($this, $count) = @_;
    my $rdf;

    $rdf = $this->BeginRDFObject();
    $rdf .= $this->BeginDesc("mq:Result");
    $rdf .= $this->Element("mq:status", "OK");
    $rdf .= $this->EndDesc("mq:Result");
    $rdf .= $this->EndRDFObject;

    return $rdf;
}

sub CreateArtistList
{
    my ($this, $doc, @ids) = @_;

    $this->{status} = "OK";
    return $this->CreateOutputRDF('artist', @ids);
}

sub CreateAlbum
{
    my ($this, $fuzzy, $id) = @_;

    $this->{status} = $fuzzy ? "Fuzzy" : "OK";
    return $this->CreateOutputRDF('album', $id);
}

sub CreateAlbumList
{
    my ($this, @ids) = @_;

    $this->{status} = "OK";
    return $this->CreateOutputRDF('album', @ids);
}

sub CreateTrackList
{
    my ($this, @ids) = @_;

    $this->{status} = "OK";
    return $this->CreateOutputRDF('track', @ids);
}

sub CreateDenseTrackList
{
    my ($this, $fuzzy, $gids) = @_;

    $this->{status} = $fuzzy ? "Fuzzy" : "OK";

    my $out;
    $out  = $this->BeginRDFObject();
    $out .= $this->BeginDesc("mq:Result");
    $out .= $this->OutputList('track', $gids);
    $out .= $this->EndDesc("mq:Result") . "\n";

    $this->{cache} = [];
    for my $id (@{$gids})
    {
    	require MusicBrainz::Server::Track;
     	my $tr = MusicBrainz::Server::Track->new($this->{DBH});
      	$tr->SetMBId($id);
       	$tr->LoadFromId();

	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($this->{DBH});
	$ar->SetId($tr->GetArtist());
	# TODO This is complaining about the ID being undef
	$ar->LoadFromId();

	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($this->{DBH});
	my @ids = $al->GetReleaseIdsFromTrackId($tr->GetId());
	$al->SetId($ids[0]);
	# TODO this is complaining that the album ID is false
	$al->LoadFromId();
	# TODO this is complaining that the trackid is false
	my $tracknum = $al->GetTrackSequence($tr->GetId());

	$this->AddToCache(0, 'artist', $ar);

	$out .= $this->OutputTrackRDF({ obj=>$tr }, $al) . "\n";
	$out .= $this->OutputArtistRDF({ obj=>$ar }) . "\n";
	$out .= $this->OutputAlbumRDF({ obj=>$al, _track=> [ $tr->GetMBId(), $tracknum ] });
    }

    $out .= $this->EndRDFObject;

    if (exists $this->{file})
    {
      	print {$this->{file}} $out;
       	$out = "";
    }

    return $out;
}

sub CreateDenseAlbum
{
    my ($this, $fuzzy, $gids) = @_;

    $this->{status} = $fuzzy ? "Fuzzy" : "OK";

    my $out;
    $out  = $this->BeginRDFObject;
    $out .= $this->BeginDesc("mq:Result");
    $out .= $this->OutputList('album', $gids);
    $out .= $this->EndDesc("mq:Result");

    $this->{cache} = [];

    for my $id (@$gids)
    {
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($this->{DBH});
	$al->SetMBId($id);
	$al->LoadFromId(1);

	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($this->{DBH});
	$ar->SetId($al->GetArtist);
	$ar->LoadFromId;
	$this->AddToCache(0, 'artist', $ar);

	require MusicBrainz::Server::Track;
	my @tracks = $al->LoadTracks;
	my $is_va = $al->GetArtist == VARTIST_ID || $al->HasMultipleTrackArtists;

	my @ids;
	my %artists;

	for my $tr (@tracks)
	{
	    if ($is_va)
	    {
		my $var = MusicBrainz::Server::Artist->new($this->{DBH});
		$var->SetId($tr->GetArtist);
		if ($var->LoadFromId)
		{
		    $this->AddToCache(0, 'artist', $var);
		    $artists{$var->GetId} = $var;
		}
	    }
	    push @ids, { id=>$tr->GetMBId, tracknum=>$tr->GetSequence };
	}

	$out .= $this->OutputAlbumRDF({ obj=>$al, _album=>\@ids });
	$out .= $this->OutputArtistRDF({ obj=>$ar });
	for my $tr (@tracks)
	{
	    $out .= $this->OutputTrackRDF({ obj=>$tr }, $al);
	}
	foreach $id (keys %artists)
	{
	    $out .= $this->OutputArtistRDF({ obj=>$artists{$id} });
	}
    }
    $out .= $this->EndRDFObject;

    if (exists $this->{file})
    {
	print {$this->{file}} $out;
	$out = "";
    }

    return $out;
}

# Check for duplicates, then add if not already in cache
sub AddToCache
{
    my ($this, $curdepth, $type, $obj) = @_;

    return undef if (!defined $curdepth || !defined $type || !defined $obj);

    # TODO: Probably best to use a hash for this, rather than scanning the
    # list each time.
    my $cache = $this->{cache};
    for my $i (@$cache)
    {
        next if ($i->{type} ne $type);
        if (($i->{id} && $i->{id} == $obj->GetId()) ||
            ($i->{mbid} && $i->{mbid} eq $obj->GetMBId))
        {
            return $i;
        }
    }

    my %item;
    $item{type} = $type;
    $item{id} = $obj->GetId();
    $item{mbid} = $obj->GetMBId();
    $item{obj} = $obj;
    $item{depth} = $curdepth;

    push @$cache, \%item;
    return \%item;
}

# Get an object from the cache, given its id
sub GetFromCache
{
    my ($this, $type, $id, $mbid) = @_;
    my ($i, $cache);

    return undef if (!defined $type || (!defined $id && !defined $mbid));

    # check to make sure this object does not already exist in the list
    $cache = $this->{cache};
    foreach $i (@$cache)
    {
        next if ($i->{type} ne $type);
        if (($id && $i->{id} && $i->{id} == $id) ||
            ($mbid && $i->{mbid} && $i->{mbid} eq $mbid))
        {
            return $i->{obj}
        }
    }
    return undef;
}

sub FindReferences
{
    my ($this, $curdepth, @ids) = @_;

    #print STDERR "\n" if ($curdepth > $this->{depth});
    return if ($curdepth > $this->{depth});

    #print STDERR "Find references: $curdepth max: $this->{depth}\n";

    $curdepth+=2;

    # Load all of the referenced objects
    my @newrefs;
    foreach my $ref (@ids)
    {
	#print STDERR "  Object: $ref->{type} ";
	#print STDERR "$ref->{id} " if defined $ref->{id};
	#print STDERR "($ref->{mbid}) " if defined $ref->{mbid};
	#print STDERR "--> ";
	my $obj = $this->GetFromCache($ref->{type}, $ref->{id}, $ref->{mbid});
	if (!defined $obj)
	{
	    $obj = $this->LoadObject($ref->{id}, $ref->{mbid}, $ref->{type});
	}
	next if (!defined $obj);

	my $cacheref = $this->AddToCache($curdepth, $ref->{type}, $obj);
	if (defined $cacheref)
	{
	    push @newrefs, $this->GetReferences($cacheref, $curdepth);
	}
    }

    $this->FindReferences($curdepth, @newrefs);
}

sub CreateOutputRDF
{
    my ($this, $type, @ids) = @_;

    die if (not defined $this->GetBaseURI() || $this->GetBaseURI() eq '');
    return $this->CreateStatus() if (!defined $ids[0]);

    my $depth = $this->GetDepth();
    # TODO sometimes $depth is not defined
    return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 1);

    my @cache;
    $this->{cache} = \@cache;

    # Create a cache of objects and add the passed object ids without
    # loading the actual objects
    my @newrefs;
    for my $id (@ids)
    {
	push @newrefs, +{ id => $id, type => $type };
    }

    # Call find references to recursively load and find referenced objects
    $this->FindReferences(0, @newrefs);

    # Now that we've compiled a list of objects, output the list and
    # the actual objects themselves

    # Output the actual list of objects, making sure to only
    # include the first few objects in the cache, not all of them.
    my $total = scalar(@ids);
    my @gids;
    for (my $i = 0; $i < $total; $i++)
    {
	if (!defined $cache[$i]->{obj})
	{
	    if (defined $cache[$i]->{id})
	    {
	       	push @gids, $cache[$i]->{id};
	    }
	}
	else
	{
	    push @gids, $cache[$i]->{obj}->GetMBId();
	}
    }

    my $out;
    $out  = $this->BeginRDFObject(exists $this->{file});
    $out .= $this->BeginDesc("mq:Result");
    $out .= $this->OutputList($type, \@gids);
    $out .= $this->EndDesc("mq:Result");

    if (exists $this->{file})
    {
	print {$this->{file}} $out;
	$out = "";
    }

    # Output all of the referenced objects. Make sure to only output
    # the objects in the cache that have been loaded. The objects that
    # have not been loaded will not be output, even though they are
    # in the cache. (They would've been output if depth was one greater)
    $total = scalar(@cache);
    for (my $i = 0; $i < $total; $i++)
    {
	next if (!defined $cache[$i]->{depth} || $cache[$i]->{depth} > $depth);

	$out .= $this->OutputRDF(\@cache, $cache[$i]);
	$out .= "\n";
	if (exists $this->{file})
	{
	    print {$this->{file}} $out;
	    $out = "";
	}
    }

    $out .= $this->EndRDFObject;
    if (exists $this->{file})
    {
	print {$this->{file}} $out;
	$out = "";
    }

    return $out;
}

sub LoadObject
{
    my ($this, $id, $mbid, $type) = @_;
    my $obj;

    if ($type eq 'artist')
    {
       	require MusicBrainz::Server::Artist;
	$obj = MusicBrainz::Server::Artist->new($this->{DBH});
    }
    elsif ($type eq 'album')
    {
       	require MusicBrainz::Server::Release;
	$obj = MusicBrainz::Server::Release->new($this->{DBH});
    }
    elsif ($type eq 'track')
    {
       	require MusicBrainz::Server::Track;
	$obj = MusicBrainz::Server::Track->new($this->{DBH});
    }
    return undef if (not defined $obj);

    if (defined $mbid)
    {
      	$obj->SetMBId($mbid);
    }
    else
    {
      	$obj->SetId($id);
    }

    if (!defined $obj->LoadFromId(1))
    {
      	return undef;
    }

    if ($type eq 'album')
    {
	my $discids = $obj->GetDiscIDs;
	my $index = 0;
	for my $t (@$discids)
	{
	    $obj->{"_cdindexid$index"} = $t->GetCDTOC->GetDiscID;
	    $index++;
	}
    }

    return $obj;
}

sub OutputList
{
    my ($this, $type, $list) = @_;

    my $rdf;
    $rdf =    $this->Element("mq:status", $this->{status});
    $rdf .=     $this->BeginDesc("mm:" . $type . "List");
    $rdf .=       $this->BeginBag();
    for my $item (@$list)
    {
	next if (!defined $item);
	$rdf .=      $this->Li($this->{baseuri}. "/$type/$item");
    }
    $rdf .=       $this->EndBag();
    $rdf .=     $this->EndDesc("mm:" . $type . "List");
    $rdf .= "\n";

    return $rdf;
}

sub GetReferences
{
    my ($this, $ref, $depth) = @_;

    return () if not defined $ref;

    # Artists do not have any references, so they are not listed here
    return $this->_GetArtistReferences($ref, $ref->{obj}, $depth)
	if ($ref->{type} eq 'artist');
    return $this->_GetAlbumReferences($ref, $ref->{obj}, $depth)
	if ($ref->{type} eq 'album');
    return $this->_GetTrackReferences($ref, $ref->{obj}, $depth)
	if ($ref->{type} eq 'track');

    # If this type is not supported return an empty list
    return ();
}

# For an Artist, add a ref for each album
sub _GetArtistReferences
{
    my ($this, $ref, $artist, $depth) = @_;
    my (@albums, @albumids, $album, %info, @ret);

    if ($artist->GetId() == VARTIST_ID ||
    $depth >= $this->{depth})
    {
	return ();
    }

    @albums = $artist->GetReleases();
    foreach $album (@albums)
    {
	next if not defined $album;
	$info{type} = 'album';
	$info{id} = $album->GetId();
	$info{obj} = undef;
	push @ret, {%info};
	push @albumids, $album->GetMBId();
    }
    $ref->{_artist} = \@albumids;

    return @ret;
}

# And for an album, add the artist ref and a ref for each track
sub _GetAlbumReferences
{
    my ($this, $ref, $album, $depth) = @_;
    # TODO get rid of %info
    my (@ret, %info);

    my $albumartist = $album->GetArtist();
    $info{type} = 'artist';
    $info{id} = $album->GetArtist();
    $info{obj} = undef;
    push @ret, {%info};

    if ($depth < $this->{depth})
    {
	my @tracks = $album->LoadTracks();
	my @trackids;
	my $is_va = $albumartist == VARTIST_ID || $album->HasMultipleTrackArtists;
	for my $track (@tracks)
	{
	    next if not defined $track;
	    if ($is_va)
	    {
		$info{type} = 'artist';
		$info{id} = $track->GetArtist();
		$info{obj} = undef;
		push @ret, {%info};
	    }

	    $info{type} = 'track';
	    $info{obj} = $track;
	    $info{id} = $track->GetId();
	    push @ret, {%info};

	    push @trackids, { id=>$track->GetMBId(),
     		tracknum=>$track->GetSequence() };
	}
	$ref->{_album} = \@trackids;
    }

    return @ret;
}

# An for a track, add the artist and album refs
sub _GetTrackReferences
{
    my ($this, $ref, $track, $depth) = @_;
    my (@ret, %info);

    $info{type} = 'artist';
    $info{id} = $track->GetArtist();
    $info{tracknum} = $track->GetSequence();
    $info{obj} = undef;
    push @ret, {%info};

    #$info{type} = 'album';
    #$info{obj} = undef;
    #push @ret, {%info};

    return @ret;
}

sub OutputRDF
{
    my ($this, $cache, $ref) = @_;

    if ($ref->{type} eq 'artist')
    {
	return $this->OutputArtistRDF($ref);
    }
    elsif ($ref->{type} eq 'album')
    {
	return $this->OutputAlbumRDF($ref);
    }
    elsif ($ref->{type} eq 'track')
    {
    	return $this->OutputTrackRDF($ref);
    }

    return "";
}

1;
# eof MM.pm
