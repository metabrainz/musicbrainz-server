#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=8 sw=4 :
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

package Artist;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Carp qw( carp cluck croak );
use DBI;
use DBDefs;
use Alias;
use Album;
use Track;
use String::Unicode::Similarity;
use Text::Unaccent;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode encode );

# Artist specific accessor function. Others are inherted from TableBase 
sub GetSortName
{
   return $_[0]->{sortname};
}

sub SetSortName
{
   $_[0]->{sortname} = $_[1];
}

# Insert an artist into the DB and return the artist id. Returns undef
# on error. The name and sortname of this artist must be set via the accesor
# functions.
sub Insert
{
    my ($this, %opts) = @_;
    $this->{new_insert} = 0;

    # Check name and sortname
    defined(my $name = $this->GetName)
	or return undef;
    my $sortname = $this->GetSortName;
    $sortname = $name if not defined $sortname;

    MusicBrainz::TrimInPlace($name, $sortname);
    $this->SetName($name);
    $this->SetSortName($sortname);

    my $sql = Sql->new($this->{DBH});

    # Check to see if this artist already exists
    my $artist = $sql->SelectSingleValue(
	"SELECT id FROM artist WHERE name ILIKE ?",
	$name,
    );
    return $artist if $artist;

    unless ($opts{no_alias})
    {
	# Check to see if the artist has an alias.
	my $alias = Alias->new($this->{DBH});
	$alias->{table} = "ArtistAlias";
	$artist = $alias->Resolve($name);
	return $artist if (defined $artist);
    }

    my $page = $this->CalculatePageIndex($this->{sortname});
    my $mbid = $this->CreateNewGlobalId;

    $sql->Do(
	"INSERT INTO artist (name, sortname, gid, modpending, page)"
	. " VALUES (?, ?, ?, 0, ?)",
	$name,
	$this->{sortname},
	$mbid,
	$page,
    );

    $artist = $sql->GetLastInsertId('Artist');
    $this->{new_insert} = 1;
    $this->{id} = $artist;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
    $engine->AddWordRefs($artist,$this->{name});

    return $artist;
}

# Remove an artist from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $refcount);

    return if (!defined $this->GetId());

    $sql = Sql->new($this->{DBH});

    # See if there are any tracks that needs this artist
    ($refcount) = $sql->GetSingleRow("Track", ["count(*)"],
                                     [ "Track.artist", $this->GetId()]);
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $this->GetId() .
            ". $refcount tracks still depend on it.\n";
        return undef;
    }

    # See if there are any albums that needs this artist
    ($refcount) = $sql->GetSingleRow("Album", ["count(*)"],
                                     [ "Album.artist", $this->GetId()]);
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $this->GetId() .
            ". $refcount albums still depend on it.\n";
        return undef;
    }

    $sql->Do("DELETE FROM artistalias WHERE ref = ?", $this->GetId);
    $sql->Do(
	"DELETE FROM artist_relation WHERE artist = ? OR ref = ?",
	$this->GetId, $this->GetId,
    );
    $sql->Do(
	"UPDATE moderation_closed SET artist = ? WHERE artist = ?",
	&ModDefs::DARTIST_ID, $this->GetId,
    );
    $sql->Do(
	"UPDATE moderation_open SET artist = ? WHERE artist = ?",
	&ModDefs::DARTIST_ID, $this->GetId,
    );

    # Remove references from artist words table
    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
    $engine->RemoveObjectRefs($this->GetId());

    $sql->Do("DELETE FROM artist WHERE id = ?", $this->GetId);

    return 1;
}

sub MergeInto
{
    my ($old, $new, $mod) = @_;
    my $sql = Sql->new($old->{DBH});

    require UserSubscription;
    my $subs = UserSubscription->new($old->{DBH});
    $subs->ArtistBeingMerged($old, $mod);

    my $o = $old->GetId;
    my $n = $new->GetId;

    $sql->Do("UPDATE artist_relation SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artist_relation SET ref    = ? WHERE ref    = ?", $n, $o);
    $sql->Do("UPDATE album           SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE track           SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_closed SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_open SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artistalias     SET ref    = ? WHERE ref    = ?", $n, $o);
    $sql->Do("DELETE FROM artist     WHERE id   = ?", $o);

    # Merge any non-album tracks albums together
    my $alb = Album->new($old->{DBH});
    my @non = $alb->FindNonAlbum($n);
    $alb->CombineNonAlbums(@non)
	if @non > 1;

    # Insert the old name as an alias for the new one
    # TODO this is often a bad idea - remove this code?
    my $al = Alias->new($old->{DBH});
    $al->SetTable("ArtistAlias");
    $al->Insert($n, $old->GetName);
}

sub UpdateName
{
    my ($this, $name) = @_;

    my $sql = Sql->new($this->{DBH});

    $sql->Do(
	"UPDATE artist SET name = ? WHERE id = ?",
	$name,
	$this->GetId,
    ) or return 0;

    # Update the search engine
    $this->RebuildWordList;

    $this->SetName($name);
    1;
}

sub UpdateSortName
{
    my ($this, $name) = @_;

    my $page = $this->CalculatePageIndex($name);
    my $sql = Sql->new($this->{DBH});

    $sql->Do(
	"UPDATE artist SET sortname = ?, page = ? WHERE id = ?",
	$name,
	$page,
	$this->GetId,
    ) or return 0;

    # Update the search engine
    $this->RebuildWordList;

    $this->SetSortName($name);
    1;
}

sub UpdateModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->GetId
	or croak "Missing artist ID in UpdateModPending";
    defined($adjust)
	or croak "Missing adjustment in UpdateModPending";

    my $sql = Sql->new($self->{DBH});
    $sql->Do(
	"UPDATE artist SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
	$adjust,
	$id,
    );
}

# The artist name has changed, or an alias has been removed
# (or possibly, in the future, been changed).  Rebuild the words for this
# artist.

sub RebuildWordList
{
    my ($this) = @_;

    my $al = Alias->new($this->{DBH});
    $al->SetTable("ArtistAlias");
    my @aliases = $al->GetList($this->GetId);
    @aliases = map { $_->[1] } @aliases;

    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
    $engine->RemoveObjectRefs($this->GetId);
    $engine->AddWordRefs($this->GetId, $_)
    	for ($this->{name}, @aliases);
}

# Load an artist record given a name. The name must match exactly.
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromName
{
    my ($this, $artistname) = @_;

    MusicBrainz::TrimInPlace($artistname) if defined $artistname;
    if (not defined $artistname or $artistname eq "")
    {
	carp "Missing artistname in LoadFromName";
	return undef;
    }

    my $sql = Sql->new($this->{DBH});

    my $row;
    {
	# First, try exact match on name
	$row = $sql->SelectSingleRowArray(
	    "SELECT id, name, gid, modpending, sortname
	    FROM artist WHERE name = ?",
	    $artistname,
	);
	last if $row;

	# Search using 'ilike' is expensive, so try the usual capitalisations
	# first using the index.
	# TODO a much better long-term solution would be to have a "searchname"
	# column on the table which is effectively "lc unac artist.name", then
	# search on that.
	my $lc = lc decode "utf-8", $artistname;
	my $uc = uc $lc;
	(my $tc = $lc) =~ s/\b(\w)/uc $1/eg;
	(my $fwu = $lc) =~ s/\A(\S+)/uc $1/e;

	$row = $sql->SelectSingleRowArray(
	    "SELECT id, name, gid, modpending, sortname
	    FROM artist WHERE name IN (?, ?, ?, ?)
	    LIMIT 1",
	    encode("utf-8", $uc),
	    encode("utf-8", $lc),
	    encode("utf-8", $tc),
	    encode("utf-8", $fwu),
	);
	last if $row;

	# Next, try a full case-insensitive search
	$row = $sql->SelectSingleRowArray(
	    "SELECT id, name, gid, modpending, sortname
	    FROM artist WHERE LOWER(name) = LOWER(?)
	    LIMIT 1",
	    $artistname,
	);
	last if $row;

        # If that failed, then try to find the artist by sortname
	$this->LoadFromSortname($artistname)
		and return 1;

        # If that failed too, then try the artist aliases
        my $alias = Alias->new($this->{DBH}, "artistalias");

        if (my $artist = $alias->Resolve($artistname))
	{
	    $this->SetId($artist);
	    $this->LoadFromId
		and return 1;
	}
    }
    $row or return undef;

    @$this{qw(
	id
	name
	mbid
	modpending
	sortname
    )} = @$row;

    return 1;
}

# Load an artist record given a sortname. The name must match exactly.
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromSortname
{
    my ($this, $sortname) = @_;

    MusicBrainz::TrimInPlace($sortname) if defined $sortname;
    if (not defined $sortname or $sortname eq "")
    {
	carp "Missing sortname in LoadFromSortname";
	return undef;
    }

    my $sql = Sql->new($this->{DBH});

    my $row = $sql->SelectSingleRowArray(
	"SELECT	id, name, gid, modpending, sortname
	FROM	artist
	WHERE	LOWER(sortname) = LOWER(?) LIMIT 1",
	$sortname,
    ) or return undef;

    @$this{qw(
	id
	name
	mbid
	modpending
	sortname
    )} = @$row;

    return 1;
}

# Load an artist record given an artist id, or an MB Id
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
   my ($this) = @_;
   my ($sql, @row);

   if (!defined $this->GetId() && !defined $this->GetMBId())
   {
        cluck "Artist::LoadFromId is called with undef Id\n"; 
        return undef;
   }

   $sql = Sql->new($this->{DBH});

   if (defined $this->GetId())
   {
	my $row = $sql->SelectSingleRowArray(
	    "SELECT id, name, GID, modpending, sortname
	    FROM artist
	    WHERE id = ?",
	    $this->GetId,
	) or return undef;
	
	@row = @$row;
   }
   else
   {
        @row = $sql->GetSingleRow("Artist", [qw(id name GID modpending sortname)],
                                  ["gid", $sql->Quote($this->GetMBId())]);
   }
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{sortname} = $row[4];
        return 1;
   }
   return undef;
}

# Pull back a section of artist names for the browse artist display.
# Given an index character ($ind), a page offset ($offset) 
# it will return an array of references to an array
# of artistid, sortname, modpending. The array is empty on error.
sub GetArtistDisplayList
{
   my ($this, $ind, $offset) = @_;
   my ($query, @info, @row, $sql, $page, $page_max, $ind_max, $un, $max_artists); 

   return if length($ind) <= 0;

   $sql = Sql->new($this->{DBH});

   use locale;
   # TODO set LC_COLLATE too?
   my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");
  
   ($page, $page_max) = $this->CalculatePageIndex($ind);
   $query = qq/select id, sortname, modpending 
                    from Artist 
                   where page >= $page and page <= $page_max/;
   $max_artists = 0;
   if ($sql->Select($query))
   {
       $max_artists = $sql->Rows();
       for(;@row = $sql->NextRow;)
       {
           my $temp = unac_string('UTF-8', $row[1]);
	   $temp = lc decode("utf-8", $temp);

           # Remove all non alpha characters to sort cleaner
           $temp =~ tr/A-Za-z0-9 //cd;

           # Change space to 0 since perl has some FUNKY collate order
           $temp =~ tr/ /0/;
           push @info, [$row[0], $row[1], $row[2], $temp];
       }
       $sql->Finish;   

       # This sort is necessary in order for us to get the right
       # ordering. Unfortunately its sorting a mainly sorted list
       # and it uses quicksort, which is BAD.
       @info = sort { $a->[3] cmp $b->[3] } @info;
       splice @info, 0, $offset;

       # Only return the three things we said we would
       splice(@$_, 3) for @info;
   }

   return ($max_artists, @info);
}

# retreive the set of albums by this artist. Returns an array of 
# references to Album objects. Refer to the Album object for details.
# The returned array is empty on error. Multiple artist albums are
# also returned by this query. Use SetId() to set the id of artist
sub GetAlbums
{
   my ($this, $novartist, $loadmeta) = @_;
   my (@albums, $sql, @row, $album, $query);

   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   if (defined $loadmeta && $loadmeta)
   {
       $query = qq/select album.id, name, modpending, GID, attributes, tracks, discids, trmids, firstreleasedate, coverarturl, asin
                     from Album, Albummeta 
                    where artist=$this->{id} and albummeta.id = album.id/;
   }
   else
   {
       $query = qq/select album.id, name, modpending, GID, attributes 
                     from Album 
                    where artist=$this->{id}/;
   }
   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist($this->{id});
            $album->SetMBId($row[3]);
            $row[4] =~ s/^\{(.*)\}$/$1/;
            $album->{attrs} = [ split /,/, $row[4] ];

            if (defined $loadmeta && $loadmeta)
            {
                $album->{trackcount} = $row[5];
                $album->{discidcount} = $row[6];
                $album->{trmidcount} = $row[7];
                $album->{firstreleasedate} = $row[8]||"";
                $album->{coverarturl} = $row[9]||"";
                $album->{asin} = $row[10]||"";
            }

            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   return @albums if (defined $novartist && $novartist);

   # then, pull in the multiple artist albums
   if (defined $loadmeta && $loadmeta)
   {
       $query = qq/select album.id, name, modpending, GID, attributes, tracks, discids, trmids, firstreleasedate
                         from album, albummeta 
                        where album.artist = / . &ModDefs::VARTIST_ID .qq/ and 
                              albummeta.id = album.id and
                              album.id in (select distinct albumjoin.album 
                                       from albumjoin, track 
                                      where track.artist = $this->{id} and 
                                            albumjoin.track = track.id)/;
   }
   else
   {
       $query = qq/select album.id, name, modpending, GID, attributes
                         from album
                        where album.artist = / . &ModDefs::VARTIST_ID .qq/ and 
                              album.id in (select distinct albumjoin.album 
                                       from albumjoin, track 
                                      where track.artist = $this->{id} and 
                                            albumjoin.track = track.id)/;
   }

   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist(&ModDefs::VARTIST_ID);
            $album->SetMBId($row[3]);
            $row[4] =~ s/^\{(.*)\}$/$1/;
            $album->{attrs} = [ split /,/, $row[4] ];

            if (defined $loadmeta && $loadmeta)
            {
                $album->{trackcount} = $row[5];
                $album->{discidcount} = $row[6];
                $album->{trmidcount} = $row[7];
                $album->{firstreleasedate} = $row[8]||"";
            }

            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   return @albums;
} 

# Retreive the set of albums by this artist given a name. Returns an array of 
# references to Album objects. Refer to the Album object for details.
sub GetAlbumsByName
{
   my ($this, $name) = @_;
   my (@albums, $sql, @row, $album);

   return undef if (!exists $this->{id});
   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   $name = $sql->Quote($name);
   if ($sql->Select(qq/select id, name, modpending 
                         from Album 
                        where name ilike $name and 
                              artist = $this->{id}/))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist($this->{id});
            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   return @albums;
} 

# Checks to see if an album by the given name exists. If no exact match is
# found, then it will attempt a fuzzy match
sub HasAlbum
{
   my ($this, $albumname, $threshold) = @_;
   my (@albums, $sql, @row, $album, @matches, $sim);

   $albumname = decode("utf-8", $albumname);

   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select id, name from 
                       Album where artist=$this->{id} order by lower(name), name/))
   {
        while(@row = $sql->NextRow)
        {
	    my $name = decode("utf-8", $row[1]);

            if (lc($name) eq lc($albumname))
            {
                push @matches, { id=>$row[0], match=>1, name=>$row[1] };
            }
            else
            {
                $sim = similarity($albumname, $name);
                if ($sim >= $threshold)
                {
                    push @matches, { id=>$row[0], match=>$sim, name=>$row[1] };
                }
            }
        }
        $sql->Finish;
   }

   # then, pull in the multiple artist albums
   if ($this->{id} != &ModDefs::VARTIST_ID &&
       $sql->Select(qq/select distinct AlbumJoin.album, Album.name, lower(Album.name) 
                         from Track, Album, AlbumJoin
                        where Track.Artist = $this->{id} and 
                              AlbumJoin.track = Track.id and 
                              AlbumJoin.album = Album.id and 
                              Album.artist = / . &ModDefs::VARTIST_ID .
                   " order by lower(Album.name), Album.name"))
   {
        while(@row = $sql->NextRow)
        {
	    my $name = decode("utf-8", $row[1]);

            if (lc($name) eq lc($albumname))
            {
                push @matches, { id=>$row[0], match=>1, name=>$row[1] };
            }
            else
            {
                $sim = similarity($albumname, $name);
                if ($sim >= $threshold)
                {
                    push @matches, { id=>$row[0], match=>$sim, name=>$row[1] };
                }
            }
        }
        $sql->Finish;
   }

   return @matches;
}

sub GetRelations
{
   my ($this) = @_;
   my (@albums, $sql, @row, $album);

   return undef if (!defined $this->{id});

   $sql = Sql->new($this->{DBH});
   return $sql->SelectListOfHashes(
	"
	SELECT a.name, a.id, t.weight
	FROM (
		SELECT artist, (SUM(weight)+1)/2 AS weight
		FROM (
			SELECT artist, weight FROM artist_relation WHERE ref = ?
			UNION
			SELECT ref, weight FROM artist_relation WHERE artist = ?
		) tt
		GROUP BY artist
	) t, artist a
	WHERE a.id = t.artist
	ORDER BY t.weight DESC, a.name
	",
	$this->{id},
	$this->{id},
    );
} 

sub RDF_URL
{
	my $this = shift;
	sprintf "http://%s/mm-2.1/artist/%s",
		&DBDefs::RDF_SERVER,
		$this->GetMBId,
	;
}

1;
