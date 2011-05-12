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
#   Foundatiog, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#
#     The function LoadTracks and LoadTracksFromMultipleArtistAlbum
#     has been merged to allow the determination of various artists
#     albums by the trackartists, not by using artistid=1
#___________________________________________________________________________

package MusicBrainz::Server::Release;
use Moose;

extends 'TableBase';

use Carp qw( cluck croak );
use DBDefs;
use Encode qw( decode );
use LocaleSaver;
use ModDefs qw( VARTIST_ID );
use MusicBrainz::Server::Language;
use MusicBrainz::Server::PUID;
use MusicBrainz::Server::Script;
use MusicBrainz::Server::Translation qw( l ln );
use POSIX qw(:locale_h);


use constant NONALBUMTRACKS_NAME => "[non-album tracks]";

use constant RELEASE_ATTR_NONALBUMTRACKS => 0;

use constant RELEASE_ATTR_ALBUM          => 1;
use constant RELEASE_ATTR_SINGLE         => 2;
use constant RELEASE_ATTR_EP             => 3;
use constant RELEASE_ATTR_COMPILATION    => 4;
use constant RELEASE_ATTR_SOUNDTRACK     => 5;
use constant RELEASE_ATTR_SPOKENWORD     => 6;
use constant RELEASE_ATTR_INTERVIEW      => 7;
use constant RELEASE_ATTR_AUDIOBOOK      => 8;
use constant RELEASE_ATTR_LIVE           => 9;
use constant RELEASE_ATTR_REMIX          => 10;
use constant RELEASE_ATTR_OTHER          => 11;

use constant RELEASE_ATTR_OFFICIAL       => 100;
use constant RELEASE_ATTR_PROMOTION      => 101;
use constant RELEASE_ATTR_BOOTLEG        => 102;
use constant RELEASE_ATTR_PSEUDO_RELEASE => 103;

use constant RELEASE_ATTR_SECTION_TYPE_START   => RELEASE_ATTR_ALBUM;
use constant RELEASE_ATTR_SECTION_TYPE_END     => RELEASE_ATTR_OTHER;
use constant RELEASE_ATTR_SECTION_STATUS_START => RELEASE_ATTR_OFFICIAL;
use constant RELEASE_ATTR_SECTION_STATUS_END   => RELEASE_ATTR_PSEUDO_RELEASE;

sub entity_type { "release" }

my %AlbumAttributeNames = (
    0 => [ "Non-Album Track", "Non-Album Tracks", l("(Special case)")],
    1 => [ "Album", "Albums", l("An album release primarily consists of previously unreleased material. This includes album re-issues, with or without bonus tracks.")],
    2 => [ "Single", "Singles", l("A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song.")],
    3 => [ "EP", "EPs", l("An EP is an Extended Play release and often contains the letters EP in the title.")],
    4 => [ "Compilation", "Compilations", l("A compilation is a collection of previously released tracks by one or more artists.")],
    5 => [ "Soundtrack", "Soundtracks", l("A soundtrack is the musical score to a movie, TV series, stage show, computer game etc.")],
    6 => [ "Spokenword", "Spokenword", l("Non-music spoken word releases.")],
    7 => [ "Interview", "Interviews", l("An interview release contains an interview with the Artist.")],
    8 => [ "Audiobook", "Audiobooks", l("An audiobook is a book read by a narrator without music.")],
    9 => [ "Live", "Live Releases", l("A release that was recorded live.")],
    10 => [ "Remix", "Remixes", l("A release that was (re)mixed from previously released material.")],
    11 => [ "Other", "Other Releases", l("Any release that does not fit any of the categories above.")],

    100 => [ "Official", "Official", l("Any release officially sanctioned by the artist and/or their record company. (Most releases will fit into this category.)"_],
    101 => [ "Promotion", "Promotions", l("A giveaway release or a release intended to promote an upcoming official release. (e.g. prerelease albums or releases included with a magazine)")],
    102 => [ "Bootleg", "Bootlegs", l("An unofficial/underground release that was not sanctioned by the artist and/or the record company.")],
    103 => [ "Pseudo-Release", "PseudoReleases", l("A pseudo-release is a duplicate release for translation/transliteration purposes.")]
);

sub LinkEntityName { "album" }

sub BUILD
{
    my ($self, $params) = @_;
    $self->{attrs} = [ 0 ];
    return $self;
}

# Accessor functions to set/get the artist id of this album
sub artist
{
    my ($self, $new_artist) = @_;

    if (defined $new_artist) { $self->{artist} = $new_artist; }
    return $self->{artist};
}

sub language_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{language} = $new_id; }
    return $self->{language};
}

sub script_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{script} = $new_id; }
    return $self->{script};
}

sub language_has_mod_pending
{
    my ($self, $new_val) = @_;

    if (defined $new_val) { $self->{modpending_lang} = $new_val; }
    return $self->{modpending_lang} || 0;
}

sub quality_has_mod_pending
{
    my ($self, $new_val) = @_;

    if (defined $new_val) { $self->{modpending_qual} = $new_val; }
    return $self->{modpending_qual};
}

sub quality
{
    my ($self, $new_quality) = @_;

    if (defined $new_quality) { $self->{quality} = $new_quality; }
    return $self->{quality};
}

sub info_url
{
    my ($self, $new_url) = @_;

    if (defined $new_url) { $self->{infourl} = $new_url; }
    return $self->{infourl};
}

sub coverart_url
{
    my ($self, $new_url) = @_;

    if (defined $new_url) { $self->{coverarturl} = $new_url; }

    my $cover_url = $self->{coverarturl};
    if ($cover_url)
    {
        # Old entries didn't include the protocol in the URL
        $cover_url = "http://images.amazon.com/$cover_url"
            if $cover_url =~ m{^/};
    }

    return $cover_url;
}


sub coverart_store
{
    my ($self, $new_store) = @_;

    if (defined $new_store) { $self->{amazon_store} = $new_store; }
    return $self->{amazon_store} || "amazon.com";
}

sub asin
{
    my ($self, $new_asin) = @_;

    if (defined $new_asin) { $self->{asin} = $new_asin; }
    return ($self->{asin} || "") =~ /(\S+)/ ? $1 : "";
}

sub language
{
    my $self = shift;
        return unless $self->language_id;
        $self->{_cached_language} ||= MusicBrainz::Server::Language->newFromId($self->dbh, $self->language_id);
    return $self->{_cached_language};
}

sub script
{
    my $self = shift;
    my $id = $self->script_id or return undef;
        $self->{_cached_script} ||= MusicBrainz::Server::Script->newFromId($self->dbh, $id);
        return $self->{_cached_script};
}

sub attribute_name           { $AlbumAttributeNames{$_[0]}->[0]; }
sub attribute_name_as_plural { $AlbumAttributeNames{$_[0]}->[1]; }
sub attribute_description    { $AlbumAttributeNames{$_[0]}->[2];}

sub attributes
{
    my $self = shift;
    my @new_attributes = @_;

    if (@new_attributes)
    {
        $self->{attrs} = [ ${ $self->{attrs} }[0], grep { defined } @new_attributes ];
    }

    my @attrs = @{ $self->{attrs} };

    # Shift off the mod pending indicator
    shift @attrs;
    return \@attrs;
}

sub release_type_and_status
{
    my $self = shift;
    my $attrs = shift || $self->attributes;
    my ($type, $status);
    for (@$attrs)
    {
        return ($_) if $_ == RELEASE_ATTR_NONALBUMTRACKS;
        $type   = $_ if $_ >= RELEASE_ATTR_SECTION_TYPE_START   and $_ <= RELEASE_ATTR_SECTION_TYPE_END;
        $status = $_ if $_ >= RELEASE_ATTR_SECTION_STATUS_START and $_ <= RELEASE_ATTR_SECTION_STATUS_END;
    }

    return ($type, $status);
}

sub release_type   { ($_[0]->release_type_and_status)[0] }
sub release_status { ($_[0]->release_type_and_status)[1] }

sub attribute_list
{
   return \%AlbumAttributeNames;
}

sub attributes_have_mod_pending
{
   return ${$_[0]->{attrs}}[0]
}

sub IsNonAlbumTracks
{
   my @attrs = @{$_[0]->{attrs}};
   return (scalar(@attrs) == 2 && $attrs[1] == RELEASE_ATTR_NONALBUMTRACKS);
}

sub FindNonAlbum
{
    my ($this, $artist) = @_;
    $artist ||= $this->artist;

    my $sql = Sql->new($this->dbh);
    my $ids = $sql->SelectSingleColumnArray(
        "SELECT id FROM album WHERE artist = ?
        AND attributes[2] = " . &RELEASE_ATTR_NONALBUMTRACKS,
        $artist,
    );

    map {
        my $id = $_;
        my $o = $this->new($this->dbh);
        $o->id($id);
        $o->LoadFromId
                or die;
        $o;
    } @$ids;
}

sub CombineNonAlbums
{
    my ($class, @albums) = @_;

    $_->{_tracks} = [ $_->LoadTracks ]
        for @albums;

    # The obvious algorithm is to keep the one with the most tracks.
    @albums = sort {
        @{$b->{_tracks}} <=> @{$a->{_tracks}}
    } @albums;

    my @tracks = map { @{ $_->{_tracks} } } @albums;

    for (@tracks)
    {
        my $temp = unaccent($_->name);
        $temp = lc decode("utf-8", $temp);
        $_->{_name} = $temp;
    }

    # Sort tracks alphabetically
    @tracks = sort {
        $a->{_name} cmp $b->{_name}
                or
        $a->id <=> $b->id
    } @tracks;

    $tracks[$_-1]{_new_sequence} = $_
        for 1..@tracks;

    # Move all the tracks onto the first album
    my $album = shift @albums;
    my $sql = Sql->new($album->{dbh});

    for my $t (@tracks)
    {
        $sql->Do(
                "UPDATE albumjoin SET album = ?, sequence = ?
                        WHERE track = ? AND album = ?",
                $album->id,
                $t->{_new_sequence},
                $t->id,
                $t->release,
        ) or die sprintf 'Failed to move track %d from release %d to %d',
                $t->id, $t->release, $album->id;
    }

    # Delete the other albums
    for my $del (@albums)
    {
        $del->LoadTracks == 0 or die;
        $del->Remove;
    }

    $album;
}

sub GetOrInsertNonAlbum
{
    my ($this, $artist) = @_;
    $artist ||= $this->artist;

    my @albums = $this->FindNonAlbum($artist);

    if (@albums)
    {
        @albums = (ref $this)->CombineNonAlbums(@albums)
                if @albums > 1;
        return $albums[0];
    }

    # There doesn't seem to be a non-album for this artist, so we'll
    # insert one.
    $this->artist($artist);
    $this->name(&NONALBUMTRACKS_NAME);
    $this->attributes(&RELEASE_ATTR_NONALBUMTRACKS);
    my $id = $this->Insert;

    $this->LoadFromId
        or die;
    return $this;
}

sub GetNextFreeTrackId
{
    my $self = shift;
    $self->IsNonAlbumTracks or die;

    my $sql = Sql->new($self->dbh);
    my $used = $sql->SelectSingleColumnArray(
        "SELECT sequence FROM albumjoin WHERE album = ?",
        $self->id,
    );
    my %used = map { $_=>1 } @$used;

    # This is probably adequate for a while to come.
    for (my $seq = 1; ; ++$seq)
    {
        return $seq unless $used{$seq};
    }
}

# Insert an album that belongs to this artist. The Artist object should've
# been loaded with a LoadFromXXXX call, or the id of this artist must be
# set before this function is called.
sub Insert
{
    my ($this) = @_;

    $this->{new_insert} = 0;
    return undef if (!exists $this->{artist} || $this->{artist} eq '');
    return undef if (!exists $this->{name} || $this->{name} eq '');

    my $sql = Sql->new($this->dbh);
    my $id = $this->CreateNewGlobalId();
    my $attrs = "{" . join(',', @{ $this->{attrs} }) . "}";
    my $page = $this->CalculatePageIndex($this->{name});
    my $lang = $this->language_id();
    my $script = $this->script_id();

    $sql->Do(qq|INSERT INTO album
                (name, artist, gid, modpending, attributes, page, language, script)
                VALUES (?, ?, ?, 0, ?, ?, ?, ?)|,
        $this->{name},
        $this->{artist},
        $id,
        $attrs,
        $page,
        $lang, # can be undef
        $script, # can be undef
    );

    my $album = $sql->GetLastInsertId('Album');
    $this->{new_insert} = 1;

    $this->{id} = $album;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    unless ($this->IsNonAlbumTracks)
    {
        $this->RebuildWordList;
    }

    return $album;
}

# Remove an album from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $album, @row);

    $album = $this->id();
    return if (!defined $album);

    $sql = Sql->new($this->dbh);
    require MusicBrainz::Server::ReleaseCDTOC;
    MusicBrainz::Server::ReleaseCDTOC->RemoveAlbum($this->{dbh}, $album);

    print STDERR "DELETE: Removed release where album was " . $album . "\n";
    require MusicBrainz::Server::ReleaseEvent;
    my $rel = MusicBrainz::Server::ReleaseEvent->new($sql->{dbh});
    $rel->RemoveByRelease($album);

    if ($sql->Select(qq|select AlbumJoin.track from AlbumJoin 
                         where AlbumJoin.album = $album|))
    {
        require MusicBrainz::Server::Track;
         my $tr = MusicBrainz::Server::Track->new($this->dbh);
         while(@row = $sql->NextRow)
         {
             print STDERR "DELETE: Removed albumjoin " . $row[0] . "\n";
             $sql->Do("DELETE FROM albumjoin WHERE track = ?", $row[0]);
             $tr->id($row[0]);
             $tr->Remove();
         }
    }
    $sql->Finish;

    # Remove relationships
    require MusicBrainz::Server::Link;
    my $link = MusicBrainz::Server::Link->new($this->dbh);
    $link->RemoveByRelease($album);

    # Remove tags
    require MusicBrainz::Server::Tag;
    my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
    $tag->RemoveReleases($this->id);

    # Remove references from album words table
    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'album');
    $engine->RemoveObjectRefs($this->id());

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->DeleteRelease($this->{dbh}, $album);

    $this->RemoveGlobalIdRedirect($album, &TableBase::TABLE_RELEASE);

    print STDERR "DELETE: Removed Album " . $album . "\n";
    $sql->Do("DELETE FROM album WHERE id = ?", $album);

    return 1;
}

sub LoadAlbumMetadata
{
     my ($this) = @_;
    my $sql = Sql->new($this->dbh);

    my $row = $sql->SelectSingleRowHash(
        "SELECT * FROM albummeta WHERE id = ?",
        $this->id,
    );

    if ($row)
    {
        $this->{trackcount} = $row->{tracks};
        $this->{discidcount} = $row->{discids};
        $this->{puidcount} = $row->{puids};
        $this->{firstreleasedate} = $row->{firstreleasedate} || "";
        $this->{coverarturl} = $row->{coverarturl};
        $this->{asin} = $row->{asin};
    } else {
        cluck "No albummeta row for album #".$this->id;
        delete @$this{qw( trackcount discidcount puidcount firstreleasedate )};
        return 0;
    }

    return 1;
}

# Given an album, query the number of tracks present in this album
# Returns the number of tracks or undef on error
has 'track_count' => (
    isa => 'Int',
    is  => 'rw',
    lazy => 1,
    default => sub {
        my $self = shift;

        return unless exists $self->{id};

        $self->LoadAlbumMetadata();
        return $self->{trackcount};
    }
);

# Given an album, query the number of discids present in this album
# Returns the number of discids or undef on error
sub discid_count
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{discidcount} || !defined $this->{discidcount})
   {
       $this->LoadAlbumMetadata();
   }

   return $this->{discidcount};
}

# Returns the number of PUIDs for this album or undef on error
sub puid_count
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{puidcount} || !defined $this->{puidcount})
   {
       $this->LoadAlbumMetadata();
   }

   return $this->{puidcount};
}

# Returns the first release date for this album or undef on error
# If there is no first release date (i.e. there are no releases), then the
# empty string is returned.
sub first_release_date
{
    my ($this) = @_;
    $this->{id} or return undef;

    $this->LoadAlbumMetadata
        unless defined $this->{firstreleasedate};

     $this->{firstreleasedate};
}

# Fetches the first release date as a triple of integers.  Missing parts are
# zero.
sub first_release_date_ymd
{
    map { 0+$_ } split '-', ($_[0]->first_release_date || "0-0-0");
}

# This function takes a track id and returns an array of album ids
# on which this track appears. The array is empty on error.
sub release_ids_from_track_id
{
    my ($this, $trackid) = @_;
    my $sql = Sql->new($this->dbh);

    my $r = $sql->SelectSingleColumnArray(
        "SELECT a.id
        FROM    album a, albumjoin j
        WHERE   j.track = ?
        AND             j.album = a.id
        ORDER BY a.attributes[1]",
        $trackid,
    );

    @$r;
}

# Load an album record. Set the album id via the id accessor
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
    my ($this, $loadmeta) = @_;
    my ($idcol, $idval);

    if ($this->id)
    {
        $idcol = "id";
        $idval = $this->id;
    }
    elsif ($this->mbid)
    {
        $idcol = "gid";
        $idval = $this->mbid;
    }
    else
    {
        cluck "MusicBrainz::Server::Release::LoadFromId called with no id or gid";
        return undef;
    }

    my $sql = Sql->new($this->dbh);
    my $row = $sql->SelectSingleRowArray(
        "SELECT a.id, name, gid, modpending, artist, attributes, "
        . "       language, script, modpending_lang, quality, modpending_qual"
        . ($loadmeta ? ", tracks, discids, firstreleasedate,coverarturl,asin,puids" : "")
        . " FROM album a"
        . ($loadmeta ? " INNER JOIN albummeta m ON m.id = a.id" : "")
        . " WHERE       a.$idcol = ?",
        $idval,
    );
    
    if (!$row)
    {
        return undef
                if ($idcol ne "gid");

        my $newid = $this->CheckGlobalIdRedirect($idval, &TableBase::TABLE_RELEASE)
                or return;
    
        $row = $sql->SelectSingleRowArray(
                "SELECT a.id, name, gid, modpending, artist, attributes, "
                . "       language, script, modpending_lang, quality, modpending_qual"
                . ($loadmeta ? ", tracks, discids, firstreleasedate,coverarturl,asin,puids" : "")
                . " FROM album a"
                . ($loadmeta ? " INNER JOIN albummeta m ON m.id = a.id" : "")
                . " WHERE       a.id = ?",
                $newid)
                or return undef;
    }

    $this->{id}              = $row->[0];
    $this->{name}            = $row->[1];
    $this->{mbid}            = $row->[2];
    $this->has_mod_pending($row->[3]);
    $this->{artist}          = $row->[4];
    $this->{attrs}           = $row->[5];
    $this->{language}        = $row->[6];
    $this->{script}          = $row->[7];
    $this->{modpending_lang} = $row->[8];
    $this->{quality}         = $row->[9];
    $this->{modpending_qual} = $row->[10];

    delete @$this{qw( trackcount discidcount firstreleasedate asin coverarturl puidcount )};
    delete @$this{qw( _discids _tracks )};

    if ($loadmeta)
    {
        $this->{trackcount}       = $row->[11];
        $this->{discidcount}      = $row->[12];
        $this->{firstreleasedate} = $row->[13] || "";
        $this->{coverarturl}      = $row->[14] || "";
        $this->{asin}             = $row->[15] || "";
        $this->{puidcount}        = $row->[16];
    }

    1;
}

# This function returns a list of album ids for a given artist and album name.
sub GetAlbumListFromName
{
   my ($this, $name) = @_;
   my (@info, $sql, @row);

   return undef if (!exists $this->{artist} || $this->{artist} eq '');

   $sql = Sql->new($this->dbh);
   if ($sql->Select("select gid, name
                         from Album
                        where name = ? and
                              artist = ?",
        $name, $this->{artist},
    ))
   {
       while(@row = $sql->NextRow())
       {
           push @info, { mbid=>$row[0], name=>$row[1] };
       }
   }
   $sql->Finish;

   return @info;
}

# Load tracks for current album. Returns an array of Track references
# The array is empty if there are no tracks or on error
sub LoadTracks
{
    my ($this) = @_;
    my (@info, $query, $sql, @row, $track);

    $sql = Sql->new($this->dbh);
  
    if (not wantarray)
    {
        return $sql->SelectSingleValue(
                "SELECT COUNT(*) FROM albumjoin WHERE album = ?",
                $this->id,
        );
    }

    $query = qq/select 
                                Track.id, 
                                Track.name, 
                                Track.artist, 
                                AlbumJoin.sequence, 
                                Track.length, 
                                Track.modpending, 
                                AlbumJoin.modpending, 
                                Artist.name, 
                                Track.gid,
                                AlbumJoin.album,
                    Track_meta.rating,
                    Track_meta.rating_count
                from 
                        Track, Track_meta, AlbumJoin, Artist
                where 
                        AlbumJoin.track = Track.id and 
                        AlbumJoin.album = ? and 
                        Track.Artist = Artist.id and
                Track_meta.id = Track.id
                order by /;
    
    $query .= $this->IsNonAlbumTracks() ? " Track.name " : " AlbumJoin.sequence ";

    if ($sql->Select($query, $this->{id}))
    {
        for(;@row = $sql->NextRow();)
        {
            require MusicBrainz::Server::Artist;
            my $ta = MusicBrainz::Server::Artist->new($this->dbh);
            $ta->id($row[2]);
            $ta->name($row[7]);

                require MusicBrainz::Server::Track;
                $track = MusicBrainz::Server::Track->new($this->dbh);
                $track->id($row[0]);
                $track->name($row[1]);
                $track->artist($ta);
                $track->sequence($row[3]);
                $track->length($row[4]);
                $track->has_mod_pending($row[5]);
                $track->SetAlbumJoinModPending($row[6]);
                $track->mbid($row[8]);
                $track->release($row[9]);
                $track->rating($row[10]);
                $track->rating_count($row[11]);
                push @info, $track;
        }
    }
    $sql->Finish;

    return @info;
}


# Find all releases for this album.  Returns a list of M::S::Release objects.
sub ReleaseEvents
{
    my ($self, $loadlabels) = @_;
    require MusicBrainz::Server::ReleaseEvent;
    my $rel = MusicBrainz::Server::ReleaseEvent->new($self->dbh);
    $rel->newFromRelease($self->id, $loadlabels);
}

sub GetDiscIDs
{
    my $self = shift;

    $self->{"_discids"} ||= do
    {
        require MusicBrainz::Server::ReleaseCDTOC;
        MusicBrainz::Server::ReleaseCDTOC->newFromRelease($self->{dbh}, $self);
    };
}

sub GetTracks
{
    my $self = shift;

    unless (defined $self->{"_tracks"})
    {
        my @tracks = $self->LoadTracks;
        $self->{"_tracks"} = \@tracks;
    }

    $self->{"_tracks"} || undef;
}

# Override the _isva flag to force the release to be displayed as VA release.
sub SetMultipleTrackArtists
{
   $_[0]->{_isva} = $_[1];
}

# Fetch the tracks from the database and check
# the track artist against each other and the
# release artist. If any are found, the release needs
# to be displayed as Various Artists.
sub has_multiple_track_artists
{
    my $self = shift;
    my ($tracks, %ar);
    
    unless (defined $self->{"_isva"})
    {
        # use release artist for comparison, for the unlikely
        # case that all the track artists are the same but
        # different than the release artist. we still diplay
        # the track artists in that case.
        
        $ar{$self->artist} = 1;
        
        # get the list of tracks and get their respective
        # artistid.
        $tracks = $self->GetTracks;
        foreach my $t (@$tracks) 
        {
                $ar{$t->artist->id} = 1;
        }
        $self->{"_isva"} = (keys %ar > 1);
    }
    $self->{"_isva"} || undef;
} 

# Fetch PUID counts for each track of the current album.
# Returns a reference to a hash, where the keys are track IDs and the values
# are the PUID counts.  Tracks with no PUIDs may or may not be in the hash.
sub LoadPUIDCount
{
     my $this = shift;
    my $sql = Sql->new($this->dbh);

    my $counts = $sql->SelectListOfLists(
        "SELECT albumjoin.track, COUNT(puidjoin.track) AS num_puid
        FROM    albumjoin, puidjoin
        WHERE   albumjoin.album = ?
        AND             albumjoin.track = puidjoin.track
        GROUP BY albumjoin.track",
        $this->id,
    );

    +{
        map {
                $_->[0] => $_->[1]
        } @$counts
    };
}

# Fetch annotations for each track of the current album.
# Returns a reference to a hash, where the keys are track IDs and the values
# are a 0 or 1 if track has annotation.  Tracks with no annotations may or may not be in the hash.
sub LoadLatestTrackAnnos
{
     my $self = shift;
    my $sql = Sql->new($self->dbh);
    
    my $annos = $sql->SelectListOfLists(
        "SELECT albumjoin.track, annotation.text != ''
        FROM    albumjoin, annotation
        WHERE   albumjoin.album = ?
        AND     albumjoin.track = annotation.rowid
        AND     annotation.type = " . &MusicBrainz::Server::Annotation::TRACK_ANNOTATION .
        "ORDER BY annotation.created ASC",
        $self->id,
    );

    +{
        map {
                $_->[0] => $_->[1]
        } @$annos
    };
}

# Given a list of albums, this function will merge the list of albums into
# the current album. All Discids and PUIDs are preserved in the process
sub MergeReleases
{
   my ($this, $opts) = @_;
   my $intoMAC = $opts->{'mac'};
   my @list = @{ $opts->{'albumids'} };
   my $merge_attributes = $opts->{'merge_attributes'};
   my $merge_langscript = $opts->{'merge_langscript'};

   my ($al, $ar, $tr, @tracks, %merged, $id, $sql);
   
   return undef if (scalar(@list) < 1);

   @tracks = $this->LoadTracks();
   return undef if (scalar(@tracks) == 0);

   # Create a hash that contains the original album
   foreach $tr (@tracks)
   {
      $merged{$tr->sequence()} = $tr;
   }

   $sql = Sql->new($this->dbh);
   # If we're merging into a MAC, then set this album to a MAC album
   if ($intoMAC)
   {
        $sql->Do(
                "UPDATE album SET artist = ? WHERE id = ?",
                VARTIST_ID,
                $this->id,
        );
   }

   my $old_attrs = join " ", $this->attributes;
   my $old_langscript = join " ", ($this->language_id||0), ($this->script_id||0);

   require MusicBrainz::Server::Release;
   $al = MusicBrainz::Server::Release->new($this->dbh);
   
   require MusicBrainz::Server::Link;
   my $link = MusicBrainz::Server::Link->new($sql->{dbh});

    require MusicBrainz::Server::Tag;
    my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});

   foreach $id (@list)
   {
       $al->id($id);
       next if (!defined $al->LoadFromId());

       @tracks = $al->LoadTracks();
       foreach $tr (@tracks)
       {
           if (exists $merged{$tr->sequence()})
           {
                # We already have that track. Move any existing PUIDs
                # to the existing track
                        my $old = $tr->id;
                        my $new = $merged{$tr->sequence()}->id;

                        my $puid = MusicBrainz::Server::PUID->new($this->dbh);
                        $puid->merge_tracks($old, $new);
                        
                        # Move relationships
                        $link->MergeTracks($old, $new);

                        # Move tags
                        $tag->MergeTracks($old, $new);

                $this->SetGlobalIdRedirect($old, $tr->mbid, $new, &TableBase::TABLE_TRACK);
           }
           else
           {
                # We don't already have that track
                $sql->Do(
                                "UPDATE albumjoin SET album = ? WHERE track = ?",
                                $this->id,
                                $tr->id,
                        );
                $merged{$tr->sequence()} = $tr;
           }

           if (!$intoMAC)
           {
                # Move that the track to the target album's artist
                $sql->Do(
                                "UPDATE track SET artist = ? WHERE id = ?",
                                $this->artist,
                                $tr->id,
                        );
           }                
       }

        $this->MergeAttributesFrom($al) if $merge_attributes;
        $this->MergeLanguageAndScriptFrom($al) if $merge_langscript;

        # Also merge the Discids
        require MusicBrainz::Server::ReleaseCDTOC;
        MusicBrainz::Server::ReleaseCDTOC->MergeReleases($this->{dbh}, $id, $this->id);

        # And the releases
        require MusicBrainz::Server::ReleaseEvent;
        my $rel = MusicBrainz::Server::ReleaseEvent->new($sql->{dbh});
        $rel->MoveFromReleaseToRelease($id, $this->id);

        # And the annotations
        require MusicBrainz::Server::Annotation;
        MusicBrainz::Server::Annotation->MergeReleases($this->{dbh}, $id, $this->id, artistid => $this->artist);

        # And the ARs
        $link->MergeReleases($id, $this->id);

        # ... and the tags
        $tag->MergeReleases($id, $this->id);

        $this->SetGlobalIdRedirect($id, $al->mbid, $this->id, &TableBase::TABLE_RELEASE);

       # Then, finally remove what is left of the old album
       $al->Remove();
   }

   my $new_attrs = join " ", $this->attributes;
   $this->UpdateAttributes if $new_attrs ne $old_attrs;

   my $new_langscript = join " ", ($this->language_id||0), ($this->script_id||0);
   $this->UpdateLanguageAndScript if $new_langscript ne $old_langscript;

   return 1;
}

sub MergeAttributesFrom
{
    my ($self, $from) = @_;
    return if $self->IsNonAlbumTracks or $from->IsNonAlbumTracks;

    my @got = $self->release_type_and_status;
    my @from = $from->release_type_and_status;

    for (0..$#got)
    {
        $got[$_] ||= $from[$_];
    }

    $self->attributes(@got);
}

sub MergeLanguageAndScriptFrom
{
    my ($self, $from) = @_;
    $self->language_id($from->language_id)
        unless $self->language_id;
    $self->script_id($from->script_id)
        unless $self->script_id;
}

# Pull back a section of various artist albums for the browse various display.
# Given an index character ($ind), a page offset ($offset) and a page length
# ($max_items) it will return an array of references to an array
# of albumid, sortname, modpending. The array is empty on error.
sub browse_selection
{
    my ($this, $ind, $offset, $limit, $artist) = @_;

    return unless length($ind) > 0;
    
    my $sql = Sql->new($this->dbh);

    my ($page_min, $page_max) = $this->CalculatePageIndex($ind);

    my $query = qq{
        SELECT a.id, a.gid, a.name, a.modpending, a.attributes, a.language, a.script,
               m.firstreleasedate, m.tracks, m.puids, m.discids
          FROM album a, albummeta m
         WHERE page BETWEEN ? AND ?
           AND m.id = a.id
        };

    my @args = (
        $page_min,
        $page_max,
        $offset
    );

    if (defined $artist)
    {
        $query .= 'AND artist = ?';
        push @args, $artist->id;
    }
    
    $query .= qq{
        ORDER BY LOWER(name)
          OFFSET ?
    };

    $sql->Select($query, @args);

    my $total_entries = $sql->Rows + $offset;

    my @rows;
    for (1 .. ($limit || 50))
    {
        my $row = $sql->NextRowHashRef
            or last;
        
        # TODO: Moose!
        my $release = MusicBrainz::Server::Release->new($this->dbh);
        $release->id($row->{id});
        $release->name($row->{name});
        $release->mbid($row->{gid});
        $release->language_id($row->{language});
        $release->script_id($row->{script});
        $release->{firstreleasedate} = $row->{firstreleasedate};
        $release->{trackcount} = $row->{tracks};
        $release->{puidcount} = $row->{puidcount};
        $release->{attrs} = $row->{attributes};
        
        push @rows, $release;
    }

    return ($total_entries, \@rows);
}

sub UpdateName
{
    my $self = shift;

    my $id = $self->id
        or croak "Missing album ID in RemoveFromAlbum";
    my $name = $self->name;
    defined($name) && $name ne ""
        or croak "Missing album name in RemoveFromAlbum";

    MusicBrainz::Server::Validation::TrimInPlace($name);
    my $page = $self->CalculatePageIndex($name);

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE album SET name = ?, page = ? WHERE id = ?",
        $name,
        $page,
        $id,
    );

    # Now remove the old name from the word index, and then
    # add the new name to the index
    $self->RebuildWordList;
}

sub UpdateQuality
{
    my $self = shift;

    my $id = $self->id
        or croak "Missing artist ID in UpdateQuality";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE album SET quality = ? WHERE id = ?",
        $self->{quality},
        $id,
    );
}

# The album name has changed.  Rebuild the words for this album.

sub RebuildWordList
{
    my ($this) = @_;

    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'album');
    $engine->AddWordRefs(
        $this->id,
        $this->name,
        1, # remove other words
    );
}

sub UpdateAttributes
{
    my ($this) = @_;

    my $attr = join ',', @{ $this->{attrs} };
    my $sql = Sql->new($this->dbh);
    $sql->Do(
        "UPDATE album SET attributes = ? WHERE id = ?",
        "{$attr}",
        $this->id,
    );
}

sub UpdateLanguageAndScript
{
    my $this = shift;

    my $sql = Sql->new($this->dbh);
    $sql->Do(
        "UPDATE album SET language = ?, script = ? WHERE id = ?",
        $this->language_id || undef,
        $this->script_id || undef,
        $this->id,
    );

    # also adjust the language of all pending moderations for this album
    # current only add album mods
    $sql->Do(
        "UPDATE moderation_open SET language = ? "
        . "WHERE tab = 'album' AND rowid = ? AND type = ? ",
        $this->language_id || undef,
        $this->id,
        &ModDefs::MOD_ADD_RELEASE, 
    );
}

sub UpdateModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
        or croak "Missing album ID in UpdateModPending";
    defined($adjust)
        or croak "Missing adjustment in UpdateModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE album SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
        $adjust,
        $id,
    );
}

sub UpdateAttributesModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
        or croak "Missing album ID in UpdateAttributesModPending";
    defined($adjust)
        or croak "Missing adjustment in UpdateAttributesModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE album SET attributes[1] = NUMERIC_LARGER(attributes[1]+?, 0) WHERE id = ?",
        $adjust,
        $id,
    );
}

sub UpdateLanguageModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
        or croak "Missing album ID in UpdateLanguageModPending";
    defined($adjust)
        or croak "Missing adjustment in UpdateLanguageModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(<<'EOF', $adjust, $id);
        UPDATE  album
        SET             modpending_lang
                                = NUMERIC_LARGER(COALESCE(modpending_lang,0)+?, 0)
        WHERE   id = ?
EOF
}

sub UpdateQualityModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
        or croak "Missing album ID in UpdateQualityModPending";
    defined($adjust)
        or croak "Missing adjustment in UpdateQualityModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
        "UPDATE album SET modpending_qual = NUMERIC_LARGER(modpending_qual+?, 0) WHERE id = ?",
        $adjust,
        $id,
    );
}


sub GetTrackSequence
{
    my ($this, $trackid) = @_;

    unless ($trackid)
    {
        cluck "MusicBrainz::Server::Release::GetTrackSequence called with false trackid\n";
        return undef;
    }

    my $sql = Sql->new($this->dbh);
    $sql->SelectSingleValue(
        "SELECT sequence FROM albumjoin WHERE album = ? AND track = ?",
        $this->id,
        $trackid,
    );
}

sub XML_URL
{
    my $this = shift;
    sprintf "http://%s/ws/1/release/%s?type=xml&inc=artist+counts+release-events+discs+tracks",
        &DBDefs::WEB_SERVER,
        $this->mbid,
    ;
}

# These two subs deal with locking down the tracks on an album once it has
# valid, non-conflicting disc ids.  In each case the track number may be
# specified (can the operation be applied to this particular track), or
# missing/undef (in which case the answer is the logical OR across all tracks,
# effectively).

sub CanAddTrack
{
    my ($self, $tracknum) = @_;

    $@ = "", return 1
        if $self->IsNonAlbumTracks;

    my $toctracks = $self->_GetTOCTracksHash;
    my $havetracks = $self->_GetTrackNumbersHash;

    if (defined $tracknum)
    {
        $tracknum = int $tracknum;

        # Sanity checks on track number
        $@ = l("{tracknum} is not a valid track number", { tracknum => $tracknum }), return 0
                if $tracknum < 1;

        # Can't add a track if we've already got a track with that number
        $@ = l("This release already has a track {tracknum}", { tracknum => $tracknum }), return 0
                if $havetracks->{$tracknum};
    }

    # If we have no disc ids, or if we do, but they suggest a conflicting
    # number of tracks, then we don't know what to suggest (yet).
    unless (keys(%$toctracks) == 1)
    {
        $@ = "", return 1;
    }

    (my $fixtracks) = keys %$toctracks;

    # For a specified track number, just disallow tracks outside of the TOC
    # range.
    if (defined $tracknum)
    {
        $@ = ln("You can't add a track {tracknum} - this release is meant to have exactly {trackcount} track",
                "You can't add a track {tracknum} - this release is meant to have exactly {trackcount} tracks",
                { tracknum => $tracknum, trackcount => $fixtracks }),
                return 0
                if $tracknum > $fixtracks;
        
        $@ = "", return 1;
    }

    # Otherwise, as for "can we add any tracks at all"... yes, if there's a
    # gap in the track sequence.
    my $gap = grep { not $havetracks->{$_} } 1 .. $fixtracks;

    $@ = l("This release already has all of its tracks"), return 0
        if not $gap;

    $@ = "", return 1;
}

sub CanRemoveTrack
{
    my ($self, $tracknum) = @_;

    $@ = "", return 1
        if $self->IsNonAlbumTracks;

    my $toctracks = $self->_GetTOCTracksHash;
    my $havetracks = $self->_GetTrackNumbersHash;

    # Can't remove a track that's not there
    $@ = l("There is no track {tracknum} on this album", { tracknum => $tracknum }), return 0
        if defined $tracknum and not $havetracks->{$tracknum};

    # If we have no disc ids, or if we do, but they suggest a conflicting
    # number of tracks, then we don't know what to suggest (yet).
    unless (keys(%$toctracks) == 1)
    {
        $@ = "", return 1;
    }

    (my $fixtracks) = keys %$toctracks;

    if (defined $tracknum)
    {
        # Disallow removal of a track if it's within the TOC range, and it's not a
        # duplicate.
        $@ = ln("You can't remove track {tracknum} - this release is meant to have exactly {trackcount} track",
                "You can't remove track {tracknum} - this release is meant to have exactly {trackcount} tracks",
                { tracknum => $tracknum, trackcount => $fixtracks }),
                return 0
                if $tracknum >= 1 and $tracknum <= $fixtracks
                        and $havetracks->{$tracknum} == 1;

        # Otherwise (outside of TOC range, or inside but duplicated)
        $@ = "", return 1;
    }

    # Otherwise, as for "can we remove any tracks at all"...
    # Yes, if there's a duplicate track number somewhere.
    $@ = "", return 1 if grep { $_ > 1 } values %$havetracks;
    # Yes, if there's a track outside of the TOC range
    $@ = "", return 1 if grep { $_ < 1 or $_ > $fixtracks } keys %$havetracks;
    # Otherwise no
    $@ = l("None of the tracks on this album are eligible for removal"), return 0;
}

sub _GetTOCTracksHash
{
    my $self = shift;
    my $discids = $self->GetDiscIDs;
    @$discids
        or return +{};

    my %h;

    for (@$discids)
    {
        my $n = $_->GetCDTOC->track_count;
        ++$h{$n};
    }

    \%h;
}

sub _GetTrackNumbersHash
{
    my $self = shift;
    my $tracks = $self->GetTracks
        or return +{};

    my %h;

    for (@$tracks)
    {
        ++$h{$_->sequence};
    }

    \%h;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
