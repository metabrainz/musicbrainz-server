#!/usr/bin/perl -w
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

package MusicBrainz::Server::Artist;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Carp qw( carp cluck croak );
use DBDefs;
use String::Similarity;
use MusicBrainz::Server::Validation qw( unaccent );
use MusicBrainz::Server::Cache;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode encode );

sub LinkEntityName { "artist" }

use constant ARTIST_TYPE_UNKNOWN	=> 0;
use constant ARTIST_TYPE_PERSON		=> 1;
use constant ARTIST_TYPE_GROUP		=> 2;

# The uncessary ."" tricks perl into using the constant value rather than its name as the hash key. Lame.
my %ArtistTypeNames = (
   ARTIST_TYPE_UNKNOWN . "" => [ 'Unknown', 'Begin Date', 'End Date' ],
   ARTIST_TYPE_PERSON . "" => [ 'Person', 'Born', 'Deceased' ],
   ARTIST_TYPE_GROUP . "" => [ 'Group', 'Founded', 'Dissolved' ],
);

sub entity_type { "artist" }

# Artist specific accessor function. Others are inherted from TableBase 
sub sort_name
{
    my ($self, $new_sort_name) = @_;

    if (defined $new_sort_name) { $self->{sortname} = $new_sort_name; }
    return $self->{sortname};
}

sub type
{
    my ($self, $new_type) = @_;

    if (defined $new_type) { $self->{type} = $new_type; }
    return defined $self->{type} ? $self->{type} : 0;
}

sub type_name
{
   return $ArtistTypeNames{$_[0]}->[0];
}

sub begin_date_name
{
   return $ArtistTypeNames{$_[0]}->[1] || 'Begin Date';
}

sub end_date_name
{
   return $ArtistTypeNames{$_[0]}->[2] || 'End Date';
}

sub resolution
{
    my ($self, $new_resolution) = @_;

    if (defined $new_resolution) { $self->{resolution} = $new_resolution; }
    return defined $self->{resolution} ? $self->{resolution} : '';
}

sub begin_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{begindate} = $new_date; }
    return defined $self->{begindate} ? $self->{begindate} : '';
}

sub begin_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->begin_date();
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->begin_date);
}

sub end_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{enddate} = $new_date; }
    return defined $self->{enddate} ? $self->{enddate} : '';
}

sub end_date_ymd
{
    my $self = shift;
    
    return ('', '', '') unless $self->end_date();
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->end_date);
}


=head2 has_complete_date_range

Returns true if the artist has both a start and end date; false otherwise

=cut

sub has_complete_date_range
{
    my $self = shift;
	return $self->begin_date && $self->end_date;
}

sub quality
{
    my ($self, $new_quality) = @_;

    if (defined $new_quality) { $self->{quality} = $new_quality; }
    return $self->{quality};
}

sub quality_has_mod_pending
{
    my ($self, $new_val) = @_;

    if (defined $new_val) { $self->{modpending_qual} = $new_val; }
    return $self->{modpending_qual};
}

sub IsValidType
{
   my $type = shift;

   if ( defined $type and $type ne ""
		and ($type == ARTIST_TYPE_UNKNOWN or 
			 $type == ARTIST_TYPE_PERSON or 
			 $type == ARTIST_TYPE_GROUP) )
   {
      return 1;
   }
   else
   {
      return 0;
   }
}

sub _id_cache_key
{
    my ($class, $id) = @_;
    "artist-id-" . int($id);
}

sub _GetMBIDCacheKey
{
    my ($class, $mbid) = @_;
    "artist-mbid-" . lc $mbid;
}

sub InvalidateCache
{
    my $self = shift;
    MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
    MusicBrainz::Server::Cache->delete($self->_GetMBIDCacheKey($self->mbid));
}


# Insert an artist into the DB and return the artist id. Returns undef
# on error. The name and sortname of this artist must be set via the accesor
# functions.
sub Insert
{
    my ($this, %opts) = @_;
    $this->{new_insert} = 0;

    # Check name and sortname
    defined(my $name = $this->name)
	or return undef;
    my $sortname = $this->sort_name;
    $sortname = $name if not defined $sortname;

    MusicBrainz::Server::Validation::TrimInPlace($name, $sortname);
    $this->name($name);
    $this->sort_name($sortname);

    my $sql = Sql->new($this->dbh);
    my $artist;

    if (!$this->resolution())
    {
        my $ar_list = $this->select_artists_by_name($name);
		foreach my $ar (@$ar_list)
		{
	    	return $ar->id if ($ar->name() eq $name);
        }
		foreach my $ar (@$ar_list)
		{
	    	return $ar->id if (lc($ar->name()) eq lc($name));
        }
    }

    unless ($opts{no_alias})
    {
		# Check to see if the artist has an alias.
		require MusicBrainz::Server::Alias;
		my $alias = MusicBrainz::Server::Alias->new($this->dbh);
		$alias->{table} = "ArtistAlias";
		$artist = $alias->Resolve($name);
		return $artist if (defined $artist);
    }

    my $page = $this->CalculatePageIndex($this->{sortname});
    my $mbid;
	if ($opts{mbid})
	{
		$mbid = $opts{mbid};
	}
	else
	{
		$mbid = $this->CreateNewGlobalId;
	}
    $this->mbid($mbid);

    $sql->Do(
	qq|INSERT INTO artist
		    (name, sortname, gid, type, resolution,
		     begindate, enddate, modpending, page)
	    VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)|,
		$this->name(),
		$this->sort_name(),
		$this->mbid,
		$this->type() || undef,
		$this->resolution() || undef,
		$this->begin_date() || undef,
		$this->end_date() || undef,
		$page,
    );


    $artist = $sql->GetLastInsertId('Artist');
    $this->{new_insert} = 1;
    $this->{id} = $artist;

    MusicBrainz::Server::Cache->delete($this->_id_cache_key($artist));
    MusicBrainz::Server::Cache->delete($this->_GetMBIDCacheKey($mbid));

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'artist');
    $engine->AddWordRefs($artist,$this->{name});

    return $artist;
}

# Remove an artist from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;

    return if (!defined $this->id());

    my $sql = Sql->new($this->dbh);
    my $refcount;

    # XXX: When are we allowed to delete an artist?  See also $artist->InUse.
    # It seems inconsistent to have the presence of tracks or albums cause
    # the delete to fail, but the presence of AR links can be trampled over.

    # See if there are any tracks that needs this artist
    $refcount = $sql->SelectSingleValue(
	"SELECT COUNT(*) FROM track WHERE artist = ?",
	$this->id,
    );
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $this->id() .
            ". $refcount tracks still depend on it.\n";
        return undef;
    }

    # See if there are any albums that needs this artist
    $refcount = $sql->SelectSingleValue(
	"SELECT COUNT(*) FROM album WHERE artist = ?",
	$this->id,
    );
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $this->id() .
            ". $refcount albums still depend on it.\n";
        return undef;
    }

    $sql->Do("DELETE FROM artistalias WHERE ref = ?", $this->id);
    $sql->Do(
		"DELETE FROM artist_relation WHERE artist = ? OR ref = ?",
		$this->id, $this->id,
    );
    $sql->Do(
		"UPDATE moderation_closed SET artist = ? WHERE artist = ?",
		&ModDefs::DARTIST_ID, $this->id,
    );
    $sql->Do(
		"UPDATE moderation_open SET artist = ? WHERE artist = ?",
		&ModDefs::DARTIST_ID, $this->id,
    );

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($this->dbh);
	$link->RemoveByArtist($this->id);

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
	$tag->RemoveArtists($this->id);

    # Remove references from artist words table
    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'artist');
    $engine->RemoveObjectRefs($this->id());

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->DeleteArtist($this->{dbh}, $this->id);

    $this->RemoveGlobalIdRedirect($this->id, &TableBase::TABLE_ARTIST);

    $sql->Do("DELETE FROM artist WHERE id = ?", $this->id);
    $this->InvalidateCache;

    return 1;
}

sub MergeInto
{
    my ($old, $new, $mod) = @_;
    my $sql = Sql->new($old->{dbh});

    require UserSubscription;
    my $subs = UserSubscription->new($old->{dbh});
    $subs->ArtistBeingMerged($old, $mod);

    my $o = $old->id;
    my $n = $new->id;

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->MergeArtists($old->{dbh}, $o, $n);

    $sql->Do("UPDATE artist_relation SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artist_relation SET ref    = ? WHERE ref    = ?", $n, $o);
    $sql->Do("UPDATE album           SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE track           SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_closed SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_open SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artistalias     SET ref    = ? WHERE ref    = ?", $n, $o);
	
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($sql->{dbh});
	$link->MergeArtists($o, $n);

	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
	$tag->MergeArtists($o, $n);

    $sql->Do("DELETE FROM artist     WHERE id   = ?", $o);
    $old->InvalidateCache;

    # Merge any non-album tracks albums together
    require MusicBrainz::Server::Release;
    my $alb = MusicBrainz::Server::Release->new($old->{dbh});
    my @non = $alb->FindNonAlbum($n);
    $alb->CombineNonAlbums(@non)
	if @non > 1;
	
    $old->SetGlobalIdRedirect($old->id, $old->mbid, $new->id, &TableBase::TABLE_ARTIST);

    # Insert the old name as an alias for the new one
    # TODO this is often a bad idea - remove this code?
    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($old->{dbh});
    $al->table("ArtistAlias");
    $al->Insert($n, $old->name);

    # Invalidate the new artist as well
    $new->InvalidateCache;
}

sub UpdateName
{
    my ($this, $name) = @_;
    MusicBrainz::Server::Validation::TrimInPlace($name);

    my $sql = Sql->new($this->dbh);

    $sql->Do(
	"UPDATE artist SET name = ? WHERE id = ?",
	$name,
	$this->id,
    ) or return 0;

    $this->InvalidateCache;

    # Update the search engine
    $this->name($name);
    $this->RebuildWordList;

    1;
}

sub UpdateSortName
{
    my ($this, $name) = @_;
    MusicBrainz::Server::Validation::TrimInPlace($name);

    my $page = $this->CalculatePageIndex($name);
    my $sql = Sql->new($this->dbh);

    $sql->Do(
	"UPDATE artist SET sortname = ?, page = ? WHERE id = ?",
	$name,
	$page,
	$this->id,
    ) or return 0;

    $this->InvalidateCache;

    # Update the search engine
    $this->sort_name($name);
    $this->RebuildWordList;

    1;
}

sub UpdateQuality
{
	my $self = shift;

	my $id = $self->id
		or croak "Missing artist ID in UpdateQuality";

	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE artist SET quality = ? WHERE id = ?",
		$self->{quality},
		$id,
	);
    $self->InvalidateCache;
}

sub Update
{
    my ($this, $new) = @_;

    my $name = $new->{ArtistName};
    my $sortname = $new->{SortName};

    my $sql = Sql->new($this->dbh);

    my %update;
    $update{name} = $new->{ArtistName} if exists $new->{ArtistName};
    $update{sortname} = $new->{SortName} if exists $new->{SortName};
    $update{type} = $new->{Type} if exists $new->{Type};
    $update{resolution} = $new->{Resolution} if exists $new->{Resolution};
    $update{begindate} = $new->{BeginDate} if exists $new->{BeginDate};
    $update{enddate} = $new->{EndDate} if exists $new->{EndDate};
    $update{quality} = $new->{Quality} if exists $new->{Quality};

    if (exists $update{'sortname'})
    {
		my $page = $this->CalculatePageIndex($update{'sortname'});
		$update{'page'} = $page;
    }

    # We map the following attributes to NULL
    $update{type} = undef if exists $update{type} and $update{type} == 0;
    $update{resolution} = undef
		if exists $update{resolution} and $update{resolution} eq '';
    $update{begindate} = undef
		if exists $update{begindate} and $update{begindate} eq '';
    $update{enddate} = undef
		if exists $update{enddate} and $update{enddate} eq '';

    my $attrlist = join ', ', map { "$_ = ?" } sort keys %update;

    my @values = map { $update{$_} } sort keys %update;

    # there is nothing to change, exit.
    return 1 unless $attrlist;

    $sql->Do("UPDATE artist SET $attrlist WHERE id = ?", @values, $this->id)
		or return 0;
    $this->InvalidateCache;

    # Update the search engine
    $this->name($name) if exists $update{name};
    $this->sort_name($sortname) if exists $update{sortname};
    $this->RebuildWordList;

    return 1;
}

sub UpdateModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
		or croak "Missing artist ID in UpdateModPending";
    defined($adjust)
		or croak "Missing adjustment in UpdateModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
		"UPDATE artist SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
		$adjust,
		$id,
    );

    $self->InvalidateCache;
}

sub UpdateQualityModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
		or croak "Missing artist ID in UpdateQualityModPending";
    defined($adjust)
		or croak "Missing adjustment in UpdateQualityModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
		"UPDATE artist SET modpending_qual = NUMERIC_LARGER(modpending_qual+?, 0) WHERE id = ?",
		$adjust,
		$id,
    );

    $self->InvalidateCache;
}

# The artist name has changed, or an alias has been removed
# (or possibly, in the future, been changed).  Rebuild the words for this
# artist.

sub RebuildWordList
{
    my ($this) = @_;

    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($this->dbh);
    $al->table("ArtistAlias");
    my @aliases = $al->GetList($this->id);
    @aliases = map { $_->[1] } @aliases;

    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'artist');
    $engine->AddWordRefs(
		$this->id,
		[ $this->name, @aliases ],
		1, # remove other words
    );
}

sub RebuildWordListForAll
{
    my $class = shift;

    my $mb_r = MusicBrainz->new; $mb_r->Login; my $sql_r = Sql->new($mb_r->{dbh});
    my $mb_w = MusicBrainz->new; $mb_w->Login; my $sql_w = Sql->new($mb_w->{dbh});

    $sql_r->Select("SELECT id FROM artist");
    my $rows = $sql_r->Rows;

    my @notloaded;
    my @failed;
    my $noerrcount = 0;
    my $n = 0;
    $| = 1;

    use Time::HiRes qw( gettimeofday tv_interval );
    my $fProgress = 1;
    my $t1 = [gettimeofday];
    my $interval;

    my $p = sub {
    	my ($pre, $post) = @_;
	no integer;
	printf $pre."%9d %3d%% %9d".$post,
    	    $n, int(100 * $n / $rows),
	    $n / ($interval||1);
    };

    $p->("", "") if $fProgress;

    while ((my $id) = $sql_r->NextRow)
    {
	$sql_w->Begin;

	eval {
	    my $ar = MusicBrainz::Server::Artist->new($mb_w->{dbh});
	    $ar->id($id);
	    if ($ar->LoadFromId)
	    {
		$ar->RebuildWordList;
	    } else {
		push @notloaded, $id;
	    }
	    $sql_w->Commit;
	};

	if (my $err = $@)
	{
	    eval { $sql_w->Rollback };
	    push @failed, $id;
	    warn "$err\n";
	} else {
	    ++$noerrcount;
	}

	++$n;
	unless ($n & 0x3F)
	{
    	    $interval = tv_interval($t1);
	    $p->("\r", "") if $fProgress;
	}
    }

    $sql_r->Finish;
    $interval = tv_interval($t1);
    $p->(($fProgress ? "\r" : ""), sprintf(" %.2f sec\n", $interval));

    printf "Total: %d  Errors: %d  Not loaded: %d  Success: %d\n",
	$n, 0+@failed, 0+@notloaded, $noerrcount-@notloaded;
}

# Return a hash of hashes for artists that match the given artist name
sub select_artists_by_name
{
    my ($this, $artistname) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($artistname) if defined $artistname;
    if (not defined $artistname or $artistname eq "")
    {
		carp "Missing artistname in select_artists_by_name";
		return [];
    }

    my $sql = Sql->new($this->dbh);
    my $artists;
    {
		# First, try exact match on name
		$artists = $sql->SelectListOfHashes(
	    "SELECT id, name, gid, modpending, sortname,
			resolution, begindate, enddate, type, quality, modpending_qual
	    FROM artist WHERE name = ?",
	    $artistname,
	);
	last if scalar(@$artists);

	# Search using 'ilike' is expensive, so try the usual capitalisations
	# first using the index.
	# TODO a much better long-term solution would be to have a "searchname"
	# column on the table which is effectively "lc unac artist.name", then
	# search on that.
	my $lc = lc decode "utf-8", $artistname;
	my $uc = uc $lc;
	(my $tc = $lc) =~ s/\b(\w)/uc $1/eg;
	(my $fwu = $lc) =~ s/\A(\S+)/uc $1/e;

	$artists = $sql->SelectListOfHashes(
	    "SELECT id, name, gid, modpending, sortname,
			resolution, begindate, enddate, type, quality, modpending_qual
	    FROM artist WHERE name IN (?, ?, ?, ?)",
	    encode("utf-8", $uc),
	    encode("utf-8", $lc),
	    encode("utf-8", $tc),
	    encode("utf-8", $fwu),
	);
	last if scalar(@$artists);

	# Next, try a full case-insensitive search
	$artists = $sql->SelectListOfHashes(
	    "SELECT id, name, gid, modpending, sortname,
			resolution, begindate, enddate, type, quality, modpending_qual
	    FROM artist WHERE LOWER(name) = LOWER(?)",
	    $artistname,
	);
	last if scalar(@$artists);

    # If that failed, then try to find the artist by sortname
	$artists = $this->select_artists_by_sort_name($artistname)
		and return $artists;

    # If that failed too, then try the artist aliases
	require MusicBrainz::Server::Alias;
    my $alias = MusicBrainz::Server::Alias->new($this->dbh, "artistalias");

    if (my $artist = $alias->Resolve($artistname))
	{
	    $artists = $sql->SelectListOfHashes(
			"SELECT id, name, gid, modpending, sortname, 
				resolution, begindate, enddate, type, quality, modpending_qual
			FROM artist WHERE id = ?",
			$artist,
	    );
	}
    }
    return [] if (!defined $artists || !scalar(@$artists));

    my @results;
    foreach my $row (@$artists)
    {
        my $ar = MusicBrainz::Server::Artist->new($this->dbh);

		$ar->id($row->{id});
		$ar->mbid($row->{gid});
		$ar->name($row->{name});
		$ar->sort_name($row->{sortname});
		$ar->has_mod_pending($row->{modpending});
		$ar->resolution($row->{resolution});
		$ar->begin_date($row->{begindate});
		$ar->end_date($row->{enddate});
		$ar->type($row->{type});
		$ar->quality($row->{quality});
		$ar->quality_has_mod_pending($row->{modpending_qual});

        push @results, $ar;
    }
    return \@results;
}

# Return a hash of hashes for artists that match the given artist's sortname
sub select_artists_by_sort_name
{
    my ($this, $sortname) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($sortname) if defined $sortname;
    if (not defined $sortname or $sortname eq "")
    {
		carp "Missing sortname in select_artists_by_sort_name";
		return [];
    }

    my $sql = Sql->new($this->dbh);

    my $artists = $sql->SelectListOfHashes(
		"SELECT	id, name, gid, modpending, sortname,
		resolution, begindate, enddate, type, quality, modpending_qual
		FROM	artist
		WHERE	LOWER(sortname) = LOWER(?)",
		$sortname,
    );
    scalar(@$artists) or return [];

    my @results;
    foreach my $row (@$artists)
    {
        my $ar = MusicBrainz::Server::Artist->new($this->dbh);

		$ar->id($row->{id});
		$ar->mbid($row->{gid});
		$ar->name($row->{name});
		$ar->sort_name($row->{sortname});
		$ar->resolution($row->{resolution});
		$ar->begin_date($row->{begindate});
		$ar->end_date($row->{enddate});
		$ar->has_mod_pending($row->{modpending});
		$ar->type($row->{type});
		$ar->quality($row->{quality});
		$ar->quality_has_mod_pending($row->{modpending_qual});

        push @results, $ar;
    }
    return \@results;
}

# Load an artist record given an artist id, or an MB Id
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
    my $this = shift;
    my $id;

    if ($id = $this->id)
    {
		my $obj = $this->newFromId($id)
	    or return undef;
		%$this = %$obj;
		return 1;
    }
    elsif ($id = $this->mbid)
    {
		my $obj = $this->newFromMBId($id)
	    or return undef;
		%$this = %$obj;
		return 1;
    }
    else
    {
       	cluck "MusicBrainz::Server::Artist::LoadFromId is called with no ID / MBID\n";
       	return undef;
    }
}

sub newFromId
{
    my $this = shift;
    $this = $this->new(shift) if not ref $this;
    my $id = shift;

    my $key = $this->_id_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
       	$$obj->dbh($this->dbh) if $$obj;
		return $$obj;
    }

    my $sql = Sql->new($this->dbh);

    $obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM artist WHERE id = ?",
				$id,
		),
    );

    $obj->{mbid} = delete $obj->{gid} if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_GetMBIDCacheKey($obj->mbid), \$obj)
		if $obj;
    $obj->dbh($this->dbh) if $obj;

    return $obj;
}

sub newFromMBId
{
    my $this = shift;
    $this = $this->new(shift) if not ref $this;
    my $id = shift;

    my $key = $this->_GetMBIDCacheKey($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
       	$$obj->dbh($this->dbh) if $$obj;
		return $$obj;
    }

    my $sql = Sql->new($this->dbh);

    $obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM artist WHERE gid = ?",
			$id,
		),
    );

	if (!$obj)
	{
		my $newid = $this->CheckGlobalIdRedirect($id, &TableBase::TABLE_ARTIST);
		if ($newid)
		{
			$obj = $this->_new_from_row(
				$sql->SelectSingleRowHash("SELECT * FROM artist WHERE id = ?", $newid)
			);
		}
	}

    $obj->{mbid} = delete $obj->{gid} if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_id_cache_key($obj->id), \$obj)
		if $obj;
    $obj->dbh($this->dbh) if $obj;

    return $obj;
}

# Pull back a section of artist names for the browse artist display.
# Given an index character ($ind), a page offset ($offset) 
# it will return an array of references to an array
# of artistid, sortname, modpending. The array is empty on error.
sub artist_browse_selection
{
   my ($this, $ind, $offset) = @_;
   my ($query, @info, @row, $sql, $page, $page_max, $ind_max, $un, $max_artists); 

   return if length($ind) <= 0;

   $sql = Sql->new($this->dbh);

   use locale;
   # TODO set LC_COLLATE too?
   my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");
  
   ($page, $page_max) = $this->CalculatePageIndex($ind);
   $query = qq/SELECT id, sortname, modpending 
                 FROM Artist 
                WHERE page >= $page AND page <= $page_max/;
   $max_artists = 0;
   if ($sql->Select($query))
   {
       $max_artists = $sql->Rows();
       for(;@row = $sql->NextRow;)
       {
           my $temp = unaccent($row[1]);
		   $temp = lc decode("utf-8", $temp);

           # Remove all non alpha characters to sort cleaner
           $temp =~ tr/A-Za-z0-9 //cd;

           # Change space to 0 since perl has some FUNKY collate order
           $temp =~ tr/ /0/;
           push @info, [$row[0], $row[1], $row[2], $temp];
       }

       # This sort is necessary in order for us to get the right
       # ordering. Unfortunately its sorting a mainly sorted list
       # and it uses quicksort, which is BAD.
       @info = sort { $a->[3] cmp $b->[3] } @info;
       splice @info, 0, $offset;

       # Only return the three things we said we would
       splice(@$_, 3) for @info;
   }

   $sql->Finish;   
   return ($max_artists, @info);
}

# retreive the set of albums by this artist. Returns an array of 
# references to Album objects. Refer to the Album object for details.
# The returned array is empty on error. Multiple artist albums are
# also returned by this query. Use id() to set the id of artist
sub select_releases
{
   my ($this, $novartist, $loadmeta, $onlyvartist) = @_;
   my (@albums, $sql, @row, $album, $query);

   return @albums if (defined $novartist && $novartist && defined $onlyvartist && $onlyvartist);

   $sql = Sql->new($this->dbh);
   if (!defined $onlyvartist || !$onlyvartist)
   {
       # First, pull in the single artist albums
       if (defined $loadmeta && $loadmeta)
       {
           $query = qq/SELECT album.id, name, modpending, GID, attributes,
                              language, script, quality, modpending_qual, tracks, discids,
                              firstreleasedate, coverarturl, asin, puids
                        FROM Album, Albummeta
                       WHERE artist=$this->{id} AND albummeta.id = album.id/;
       }
       else
       {
           $query = qq/SELECT album.id, name, modpending, GID,
                              attributes, language, script, quality, modpending_qual
                         FROM Album
                        WHERE artist=$this->{id}/;
       }
       if ($sql->Select($query))
       {
            while(@row = $sql->NextRow)
            {
                require MusicBrainz::Server::Release;
                $album = MusicBrainz::Server::Release->new($this->dbh);
                $album->id($row[0]);
                $album->name($row[1]);
                $album->has_mod_pending($row[2]);
                $album->artist($this->{id});
                $album->mbid($row[3]);
                $album->{attrs} = $row[4];
                $album->language_id($row[5]);
                $album->script_id($row[6]);
                $album->quality($row[7]);
                $album->quality_has_mod_pending($row[8]);

                if (defined $loadmeta && $loadmeta)
                {
                    $album->{trackcount}       = $row[9];
                    $album->{discidcount}      = $row[10];
                    $album->{firstreleasedate} = $row[11] || "";
                    $album->{coverarturl}      = $row[12] || "";
                    $album->{asin}             = $row[13] || "";
                    $album->{puidcount}        = $row[14] || 0;
                }

                push @albums, $album;
                undef $album;
            }
       }

       $sql->Finish;
   }
   return @albums if (defined $novartist && $novartist);

   # then, pull in the multiple artist albums
   if (defined $loadmeta && $loadmeta)
   {
       $query = qq/SELECT album.id, album.artist, name, modpending, GID, attributes, language,
                          script, quality, modpending_qual, tracks, discids, firstreleasedate, puids
                     FROM album, albummeta
                    WHERE album.artist != $this->{id} AND
                          albummeta.id = album.id AND
                          album.id IN (SELECT DISTINCT albumjoin.album
                                         FROM albumjoin, track
                                        WHERE track.artist = $this->{id} AND
                                              albumjoin.track = track.id)/;
   }
   else
   {
       $query = qq/SELECT album.id, album.artist, name, modpending, GID,
                          attributes, language, script, quality, modpending_qual
                     FROM album
                    WHERE album.artist != $this->{id} AND
                          album.id IN (SELECT DISTINCT albumjoin.album
                                         FROM albumjoin, track
                                        WHERE track.artist = $this->{id} AND
                                              albumjoin.track = track.id)/;
   }

   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow)
        {
            require MusicBrainz::Server::Release;
            $album = MusicBrainz::Server::Release->new($this->dbh);
            $album->id($row[0]);
            $album->artist($row[1]);
            $album->name($row[2]);
            $album->has_mod_pending($row[3]);
            $album->mbid($row[4]);
            $album->{attrs} = $row[5];
            $album->language_id($row[6]);
            $album->script_id($row[7]);
            $album->quality($row[8]);
            $album->quality_has_mod_pending($row[9]);

            if (defined $loadmeta && $loadmeta)
            {
                $album->{trackcount}       = $row[10];
                $album->{discidcount}      = $row[11];
                $album->{firstreleasedate} = $row[12] || "";
                $album->{puidcount}        = $row[13] || 0;
            }

            push @albums, $album;
            undef $album;
        }
   }

    $sql->Finish;
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
   $sql = Sql->new($this->dbh);
   if ($sql->Select(qq/SELECT id, name
			 FROM Album
			WHERE artist=$this->{id}
                     ORDER BY lower(name), name/))
   {
        while(@row = $sql->NextRow)
        {
            my $name = decode("utf-8", $row[1]);
	    my $sim = lc $name eq lc $albumname ? 1
	            :                             similarity($albumname, $name);

	    next unless $sim >= $threshold;

	    my $release = new MusicBrainz::Server::Release($this->{dbh});
	    $release->id($row[0]);
	    $release->name($row[1]);
	    $release->{match} = $sim;

	    push @matches, $release;
        }
   }

    $sql->Finish;

   # then, pull in the multiple artist albums
   if ($this->{id} != &ModDefs::VARTIST_ID)
   {
       $sql->Select(qq/select distinct AlbumJoin.album, Album.name, lower(Album.name) 
                         from Track, Album, AlbumJoin
                        where Track.Artist = $this->{id} and 
                              AlbumJoin.track = Track.id and 
                              AlbumJoin.album = Album.id and 
                              Album.artist = / . &ModDefs::VARTIST_ID .
                   " order by lower(Album.name), Album.name");

        while(@row = $sql->NextRow)
        {
	    my $name = decode("utf-8", $row[1]);
	    my $sim = lc $name eq lc $albumname ? 1
	            :                             similarity($albumname, $name);

	    next unless $sim >= $threshold;

	    my $release = new MusicBrainz::Server::Release($this->{dbh});
	    $release->id($row[0]);
	    $release->name($row[1]);

            push @matches, $release;
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

   $sql = Sql->new($this->dbh);
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

sub XML_URL
{
	my $this = shift;
	sprintf "http://%s/ws/1/artist/%s?type=xml&inc=aliases",
		&DBDefs::RDF_SERVER,
		$this->mbid,
	;
}

sub GetSubscribers
{
    my $self = shift;
    require UserSubscription;
    return UserSubscription->GetSubscribersForArtist($self->{dbh}, $self->id);
}

=head2 subscriber_count

Get's the amount of moderators subscribed to this artist

=cut

sub subscriber_count
{
	my $self = shift;
	return scalar $self->GetSubscribers;
}

sub InUse
{
    my ($self) = @_;
    my $sql = Sql->new($self->dbh);

    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM album WHERE artist = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM track WHERE artist = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_album_artist WHERE link1 = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_artist_artist WHERE link1 = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_artist_artist WHERE link0 = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_artist_track WHERE link0 = ? LIMIT 1",
		$self->id,
    );
    return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_artist_url WHERE link0 = ? LIMIT 1",
		$self->id,
    );
    return 0;
}

1;
# eof Artist.pm
