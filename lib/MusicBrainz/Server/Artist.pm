package MusicBrainz::Server::Artist;
use Moose;
extends 'TableBase';

use Carp qw( carp cluck croak );
use DBDefs;
use Encode qw( decode encode );
use LocaleSaver;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Validation qw( unaccent );
use POSIX qw(:locale_h);
use String::Similarity;

use constant ARTIST_TYPE_UNKNOWN	=> 0;
use constant ARTIST_TYPE_PERSON		=> 1;
use constant ARTIST_TYPE_GROUP		=> 2;

# The uncessary ."" tricks perl into using the constant value rather than its name as the hash key. Lame.
my %ArtistTypeNames = (
   ARTIST_TYPE_UNKNOWN . "" => [ 'Unknown', 'Begin Date', 'End Date' ],
   ARTIST_TYPE_PERSON  . "" => [ 'Person', 'Born', 'Deceased' ],
   ARTIST_TYPE_GROUP   . "" => [ 'Group', 'Founded', 'Dissolved' ],
);

sub LinkEntityName { "artist" }
sub entity_type { "artist" }

=head1 SLOTS

=head2 sort_name

The name used to sort this artist

=cut

has 'sort_name' => (
	is => 'rw',
	init_arg => 'sortname',
);

=head2 type

The type of this artist

=cut

has 'type' => (
	is => 'rw',
);

=head2 resolution

Returns a short comment, usually used for disambiguation against similarly named artists,
about this artist.

=cut

has 'resolution' => (
	is => 'rw',
);

=head2 begin_date

The date this artist was born, or the group was founded.

=cut

has 'begin_date' => (
	is => 'rw',
	init_arg => 'begindate'
);

=head2 end_date

The date this artist deceased, or the group disbanded.

=cut

has 'end_date' => (
	is => 'rw',
	init_arg => 'enddate'
);

=head2 quality

The quality level of this artist

=cut

has 'quality' => (
	is => 'rw'
);

=head2 quality_has_mod_pending

Whether the quality level of this artist has pending edits in the edit queue

=cut

has 'quality_has_mod_pending' => (
	is => 'rw',
	init_arg => 'modpending_qual'
);

=head1 METHODS

=head2 TEMPLATE HELPERS

=head3 type_name [$type]

Returns a human readable string of an artist type.

If called as an object method, the C<type> of this object will be used. Else, the
type passed as $type will be used.

=cut

sub type_name
{
	my $type = shift;
	$type = ref $type ? $type->type : $type;
	
	$ArtistTypeNames{$type}->[0];
}

=head3 begin_date_name

Return a human readable string of the 'begin date' of this artist, depending on the artist type.

Follows the same calling conventions as L<type_name>.

=cut

sub begin_date_name
{
	my $type = shift;
	$type = ref $type ? $type->type : $type;
	
	return $ArtistTypeNames{$type}->[1] || 'Begin Date';
}

=head3 end_date_name

Return a human readable string of the 'begin date' of this artist, depending on the artist type.

Follows the same calling conventions as L<type_name>.

=cut

sub end_date_name
{
	my $type = shift;
	$type = ref $type ? $type->type : $type;
	
	return $ArtistTypeNames{$type}->[2] || 'End Date';
}

=head2 has_complete_date_range

Returns true if the artist has both a start and end date; false otherwise

=cut

sub has_complete_date_range
{
    my $self = shift;
	return $self->begin_date && $self->end_date;
}

=head2 PACKAGE METHODS

=head3 is_valid_type $type

Check if a given C<$type> is a valid artist type

=cut

sub is_valid_type
{
    my $type = shift;
    return exists $ArtistTypeNames{$type . ""};
}

=head2 begin_date_ymd

Returns the begin date of an artist, as a list.

=cut

sub begin_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->begin_date;
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->begin_date);
}

=head2 end_date_ymd

Returns the end date of an artist, as a list.

=cut

sub end_date_ymd
{
    my $self = shift;
    
    return ('', '', '') unless $self->end_date;
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->end_date);
}

sub _id_cache_key
{
    my ($class, $id) = @_;
    "artist-id-" . int($id);
}

sub _mbid_cache_key
{
    my ($class, $mbid) = @_;
    "artist-mbid-" . lc $mbid;
}

sub _invalidate_cache
{
    my $self = shift;
    MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
    MusicBrainz::Server::Cache->delete($self->_mbid_cache_key($self->mbid));
}

=head2 Insert

Insert an artist into the DB and return the artist id. Returns undef on error.
The name and sortname of this artist must be set via the accesor functions.

=cut

sub Insert
{
    my ($self, %opts) = @_;

    $self->{new_insert} = 0;

    # Check name and sortname
    my $name = $self->name;
    my $sort_name = $self->sort_name || $name;

    $name or return undef;

    MusicBrainz::Server::Validation::TrimInPlace($name, $sort_name);
    $self->name($name);
    $self->sort_name($sort_name);

    my $sql = Sql->new($self->dbh);

    if (!$self->resolution)
    {
        my $ar_list = $self->find_artists_by_name($name);
        my @dupes = grep { lc $_->name eq lc $name } @$ar_list;

        if (scalar @dupes) {
            return $dupes[0]->id;
        }
    }

    unless ($opts{no_alias})
    {
		# Check to see if the artist has an alias.
		require MusicBrainz::Server::Alias;
		my $alias = MusicBrainz::Server::Alias->new(
			$self->dbh,
			table => 'ArtistAlias'
		);
		
		my $artist = $alias->Resolve($name);
		return $artist
			if defined $artist;
    }

    my $page = $self->CalculatePageIndex($self->sort_name);
    $self->mbid($opts{mbid} ? $opts{mbid} : $self->CreateNewGlobalId);

    $sql->Do(qq{
		INSERT INTO artist
		    (name, sortname, gid, type, resolution,
		     begindate, enddate, modpending, page)
	    VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)
	},
		$self->name,
		$self->sort_name,
		$self->mbid,
		$self->type || undef,
		$self->resolution || undef,
		$self->begin_date || undef,
		$self->end_date || undef,
		$page,
    );

    $self->id($sql->GetLastInsertId('Artist'));
    $self->{new_insert} = 1;

	$self->_invalidate_cache;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.
    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, 'artist');
    $engine->AddWordRefs($self->id, $self->{name});

    return $self->id;
}

=head2

Remove an artist from the database. Set the id via the accessor function.

=cut

sub Remove
{
    my ($self) = @_;

    return
		unless defined $self->id;

    my $sql = Sql->new($self->dbh);
    my $refcount;

    # XXX: When are we allowed to delete an artist?  See also $artist->InUse.
    # It seems inconsistent to have the presence of tracks or albums cause
    # the delete to fail, but the presence of AR links can be trampled over.

    # See if there are any tracks that needs this artist
    $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM track WHERE artist = ?",
		$self->id,
    );
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $self->id .
            ". $refcount tracks still depend on it.\n";
        return;
    }

    # See if there are any albums that needs this artist
    $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM album WHERE artist = ?",
		$self->id,
    );
    if ($refcount > 0)
    {
        print STDERR "Cannot remove artist ". $self->id .
            ". $refcount albums still depend on it.\n";
        return undef;
    }

    $sql->Do(
		"DELETE FROM artistalias WHERE ref = ?",
		$self->id
	);
    $sql->Do(
		"DELETE FROM artist_relation WHERE artist = ? OR ref = ?",
		$self->id, $self->id,
    );
    $sql->Do(
		"UPDATE moderation_closed SET artist = ? WHERE artist = ?",
		&ModDefs::DARTIST_ID, $self->id,
    );
    $sql->Do(
		"UPDATE moderation_open SET artist = ? WHERE artist = ?",
		&ModDefs::DARTIST_ID, $self->id,
    );

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($self->dbh);
	$link->RemoveByArtist($self->id);

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($self->dbh);
	$tag->RemoveArtists($self->id);

 	# Remove ratings
	require MusicBrainz::Server::Rating;
	my $ratings = MusicBrainz::Server::Rating->new($self->dbh);
	$ratings->RemoveArtists($self->id);

    # Remove references from artist words table
    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, 'artist');
    $engine->RemoveObjectRefs($self->id());

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->DeleteArtist($self->dbh, $self->id);

    $self->RemoveGlobalIdRedirect($self->id, &TableBase::TABLE_ARTIST);

    $sql->Do("DELETE FROM artist WHERE id = ?", $self->id);
    $self->_invalidate_cache;

    return 1;
}

sub MergeInto
{
    my ($old, $new, $mod) = @_;
    my $sql = Sql->new($old->dbh);

    require UserSubscription;
    my $subs = UserSubscription->new($old->dbh);
    $subs->ArtistBeingMerged($old, $mod);

    my $o = $old->id;
    my $n = $new->id;

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->MergeArtists($old->dbh, $o, $n);

    $sql->Do("UPDATE artist_relation   SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artist_relation   SET ref    = ? WHERE ref    = ?", $n, $o);
    $sql->Do("UPDATE album             SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE track             SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_closed SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE moderation_open   SET artist = ? WHERE artist = ?", $n, $o);
    $sql->Do("UPDATE artistalias       SET ref    = ? WHERE ref    = ?", $n, $o);

    require MusicBrainz::Server::Link;
    my $link = MusicBrainz::Server::Link->new($old->dbh);
    $link->MergeArtists($o, $n);

    require MusicBrainz::Server::Tag;
    my $tag = MusicBrainz::Server::Tag->new($old->dbh);
    $tag->MergeArtists($o, $n);

    require MusicBrainz::Server::Rating;
    my $ratings = MusicBrainz::Server::Rating->new($old->dbh);
    $ratings->MergeArtists($o, $n);

    $sql->Do("DELETE FROM artist WHERE id   = ?", $o);
    $old->_invalidate_cache;

    # Merge any non-album tracks albums together
    require MusicBrainz::Server::Release;
    my $alb = MusicBrainz::Server::Release->new($old->dbh);
    my @non = $alb->FindNonAlbum($n);
    $alb->CombineNonAlbums(@non)
        if @non > 1;

    $old->SetGlobalIdRedirect($old->id, $old->mbid, $new->id, &TableBase::TABLE_ARTIST);

    # Insert the old name as an alias for the new one
    # TODO this is often a bad idea - remove this code?
    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($old->dbh);
    $al->table("ArtistAlias");
    $al->Insert($n, $old->name);

    # Invalidate the new artist as well
    $new->_invalidate_cache;
}

sub UpdateName
{
    my ($self, $new_name) = @_;
    MusicBrainz::Server::Validation::TrimInPlace($new_name);

    my $sql = Sql->new($self->dbh);

    $sql->Do(
        "UPDATE artist SET name = ? WHERE id = ?",
        $new_name,
        $self->id,
    ) or return;

    $self->_invalidate_cache;

    # Update the search engine
    $self->name($new_name);
    $self->RebuildWordList;

    return 1;
}

sub UpdateSortName
{
    my ($self, $new_sort_name) = @_;
    MusicBrainz::Server::Validation::TrimInPlace($new_sort_name);

    my $page = $self->CalculatePageIndex($new_sort_name);
    my $sql = Sql->new($self->dbh);

    $sql->Do(
        "UPDATE artist SET sortname = ?, page = ? WHERE id = ?",
        $new_sort_name,
        $page,
        $self->id,
    ) or return;

    $self->_invalidate_cache;

    # Update the search engine
    $self->sort_name($new_sort_name);
    $self->RebuildWordList;

    return 1;
}

sub UpdateQuality
{
    my ($self, $new_quality) = @_;

    my $id = $self->id
        or croak "Missing artist ID in UpdateQuality";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE artist SET quality = ? WHERE id = ?",
        $new_quality,
        $id,
    );

    $self->_invalidate_cache;
    $self->quality($new_quality);
    
    return 1;
}

sub Update
{
    my ($self, $new) = @_;

    my $name      = $new->{ArtistName};
    my $sort_name = $new->{SortName};

    my $sql = Sql->new($self->dbh);

    my %update;
    $update{name}       = $new->{ArtistName} if exists $new->{ArtistName};
    $update{sortname}   = $new->{SortName}   if exists $new->{SortName};
    $update{type}       = $new->{Type}       if exists $new->{Type};
    $update{resolution} = $new->{Resolution} if exists $new->{Resolution};
    $update{begindate}  = $new->{BeginDate}  if exists $new->{BeginDate};
    $update{enddate}    = $new->{EndDate}    if exists $new->{EndDate};
    $update{quality}    = $new->{Quality}    if exists $new->{Quality};

    if (exists $update{sortname})
    {
		my $page = $self->CalculatePageIndex($update{sortname});
		$update{page} = $page;
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

    $sql->Do("UPDATE artist SET $attrlist WHERE id = ?", @values, $self->id)
		or return 0;

    $self->_invalidate_cache;

    # Update the search engine
    $self->name($name) if exists $update{name};
    $self->sort_name($sort_name) if exists $update{sortname};
    $self->RebuildWordList;

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

    $self->_invalidate_cache;
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

    $self->_invalidate_cache;
}

=head2 RebuildWorldList

The artist name has changed, or an alias has been removed
(or possibly, in the future, been changed).  Rebuild the words for this
artist.

=cut

sub RebuildWordList
{
    my $self = shift;

    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($self->dbh, 'ArtistAlias');

    my @aliases = map { $_->name } $al->load_all($self->id);

    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, 'artist');
    $engine->AddWordRefs(
        $self->id,
        [ $self->name, @aliases ],
        1, # remove other words
    );
}

=head2 find_artists_by_name

Return an arrayref of artists that match a given query

=cut

sub find_artists_by_name
{
    my ($self, $name) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($name);
    if (!defined $name || $name eq "")
    {
        carp "Missing artistname in find_artists_by_name";
        return [];
    }

    my $sql = Sql->new($self->dbh);
    my $artists;
    {
        # First, try exact match on name
        $artists = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, sortname,
                    resolution, begindate, enddate, type, quality, modpending_qual
               FROM artist
              WHERE name = ?",
            $name,
        );
        last if scalar(@$artists);

        # Search using 'ilike' is expensive, so try the usual capitalisations
        # first using the index.
        # TODO a much better long-term solution would be to have a "searchname"
        # column on the table which is effectively "lc unac artist.name", then
        # search on that.
        my $lc = lc decode "utf-8", $name;
        my $uc = uc $lc;
        (my $tc = $lc) =~ s/\b(\w)/uc $1/eg;
        (my $fwu = $lc) =~ s/\A(\S+)/uc $1/e;

        $artists = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, sortname,
                    resolution, begindate, enddate, type, quality, modpending_qual
               FROM artist
              WHERE name IN (?, ?, ?, ?)",
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
               FROM artist
              WHERE LOWER(name) = LOWER(?)",
            $name,
        );
        last if scalar(@$artists);
    };

    # If that failed, then try to find the artist by sortname
    $artists = $self->find_artists_by_sort_name($name)
        and return $artists;

    # If that failed too, then try the artist aliases
    require MusicBrainz::Server::Alias;
    my $alias = MusicBrainz::Server::Alias->new($self->dbh, table => "artistalias");

    if (my $artist = $alias->Resolve($name))
    {
        $artists = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, sortname, 
                    resolution, begindate, enddate, type, quality, modpending_qual
               FROM artist
              WHERE id = ?",
            $artist,
        );
    }

    return []
        if !defined $artists || !scalar(@$artists);

    my @results = map { MusicBrainz::Server::Artist->new($self->dbh, $_) } @$artists;
    return [ @results ];
}

=head2

Return a ArrayRef of artists that match the given artist's sort name.

=cut

sub find_artists_by_sort_name
{
    my ($self, $sort_name) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($sort_name)
        if defined $sort_name;

    if (not defined $sort_name or $sort_name eq "")
    {
        carp "Missing sortname in find_artists_by_sort_name";
        return [];
    }

    my $sql = Sql->new($self->dbh);

    my $artists = $sql->SelectListOfHashes(
        "SELECT id, name, gid, modpending, sortname,
                resolution, begindate, enddate, type, quality, modpending_qual
           FROM artist
          WHERE LOWER(sortname) = LOWER(?)",
        $sort_name,
    );
    scalar(@$artists) or return [];

    my @results = map { MusicBrainz::Server::Artist->new($self->dbh, $_) } @$artists;
    return [ @results ];
}

=head2 LoadFromId

Load an artist record given an artist id, or an MB Id
returns 1 on success, undef otherwise. Access the artist info via the
accessor functions.

=cut

sub LoadFromId
{
    my $self = shift;
    my $id;

    if ($id = $self->id)
    {
        my $obj = $self->load_from_id($id)
            or return undef;
        
        %$self = %$obj;
        return 1;
    }
    elsif ($id = $self->mbid)
    {
        my $obj = $self->load_from_mbid($id)
            or return undef;

        %$self = %$obj;
        return 1;
    }
    else
    {
        cluck "MusicBrainz::Server::Artist::LoadFromId is called with no ID / MBID\n";
        return;
    }
}

sub load_from_id
{
    my $self = shift;
    $self = $self->new(shift) if not ref $self;

    my $id = shift;

    my $key = $self->_id_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
        $$obj->dbh($self->dbh) if $$obj;
        return $$obj;
    }

    my $sql = Sql->new($self->dbh);

    $obj = $self->_new_from_row(
        $sql->SelectSingleRowHash(
            "SELECT * FROM artist WHERE id = ?",
            $id,
        ),
    );
    
    return unless $obj;

    $obj->mbid($obj->{gid}) if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_mbid_cache_key($obj->mbid), \$obj)
        if $obj;
    $obj->dbh($self->dbh) if $obj;

    return $obj;
}

sub load_from_mbid
{
    my $self = shift;
    $self = $self->new(shift) if not ref $self;

    my $id = shift;

    my $key = $self->_mbid_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
        $$obj->dbh($self->dbh) if $$obj;
        return $$obj;
    }

    my $sql = Sql->new($self->dbh);

    $obj = $self->_new_from_row(
        $sql->SelectSingleRowHash(
            "SELECT * FROM artist WHERE gid = ?",
            $id,
        ),
    );

    if (!$obj)
    {
        my $newid = $self->CheckGlobalIdRedirect($id, &TableBase::TABLE_ARTIST);
        if ($newid)
        {
            $obj = $self->_new_from_row(
                $sql->SelectSingleRowHash("SELECT * FROM artist WHERE id = ?", $newid)
            );
        }
    }
    
    return unless $obj;

    $obj->{mbid} = delete $obj->{gid} if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_id_cache_key($obj->id), \$obj)
        if $obj;
    $obj->dbh($self->dbh) if $obj;

    return $obj;
}

=head2 artist_browse_selection

Pull back a section of artist names for the browse artist display.
Given an index character ($ind), a page offset ($offset) 
it will return an array of references to an array
of artistid, sortname, modpending. The array is empty on error.

=cut

sub artist_browse_selection
{
    my ($self, $ind, $offset, $limit) = @_;
    
    return unless length($ind) > 0;
    
    $limit ||= 50;
    
    my $sql = Sql->new($self->dbh);
    my ($page, $page_max) = $self->CalculatePageIndex($ind);
    
    $sql->Select(qq{
        SELECT id, sortname, modpending, resolution
          FROM artist 
         WHERE page >= ? AND page <= ?
      ORDER BY LOWER(sortname)
        OFFSET ?
        },
        $page,
        $page_max,
        $offset
    ) or return (0, []);
    
    my $total_entries = $sql->Rows + $offset;
    
    my @rows;
    for (1 .. $limit)
    {
        my $row = $sql->NextRowHashRef
            or last;
        push @rows, MusicBrainz::Server::Artist->new($self->dbh, $row);
    }

    $sql->Finish;
    return ($total_entries, \@rows);
}

=head2 releases

Retreive the set of albums by this artist. Returns an array of 
references to Album objects. Refer to the Album object for details.
The returned array is empty on error. Multiple artist albums are
also returned by this query. Use id() to set the id of artist

=cut

sub releases
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
                              firstreleasedate, coverarturl, asin, puids,
                              rating, rating_count
                        FROM Album, Albummeta
                       WHERE artist = ? AND albummeta.id = album.id/;
       }
       else
       {
           $query = qq/SELECT album.id, name, modpending, GID,
                              attributes, language, script, quality, modpending_qual
                         FROM Album
                        WHERE artist = ?/;
       }
       if ($sql->Select($query, $this->id))
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
                    $album->{rating}           = $row[15] || 0;
                    $album->{rating_count}     = $row[16] || 0;
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

=head2 has_release

Checks to see if a release by the given name exists. If no exact match is
found, then it will attempt a fuzzy match

=cut

sub has_release
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

sub relations
{
   my ($this) = @_;
   my (@albums, $sql, @row, $album);

   return undef if (!defined $this->{id});

   $sql = Sql->new($this->dbh);
   return $sql->SelectListOfHashes(
		"
		SELECT a.name, a.gid, t.weight
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

sub subscribers
{
    my $self = shift;
    require UserSubscription;
    return UserSubscription->GetSubscribersForArtist($self->{dbh}, $self->id);
}

=head1 LICENSE

MusicBrainz -- the open internet music database

Copyright (C) 2000 Robert Kaye

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

no Moose;
__PACKAGE__->meta->make_immutable;
1;
# eof Artist.pm
