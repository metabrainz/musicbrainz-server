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

package Insert;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use Artist;
use Album;
use Track;
use Alias;
use TRM;
use Discid;
use Moderation;
use ModDefs;
use Sql;

sub new
{
    my ($type, $dbh) = @_;
    my $this = {};

    # Use the db handle from the musicbrainz object
    $this->{DBH} = $dbh;
    $this->{type} = $type;

    bless $this;
    return $this;
}  

sub GetError
{
    my ($this) = @_;

    return $this->{error};
}

# Called by (with argument patterns):
#	admin/freedb.pl
#	QuerySupport->SubmitTrack
#		artist => ?
#		sortname => same as artist
#		album => ?
#		tracks => [
#			{
#				track => $name,
#				tracknum => $seq,
#				duration => $len, 
#				trmid => $TRM
#			}
#		] (always exactly one track)
#	MOD_ADD_ALBUM PreInsert
#		EITHER artist+sortname OR artistid
#		album => name
#		OPTIONAL cdindexid => ..., toc => ...
#		forcenewalbum => 1
#		attrs => [ possibly empty list of attrs ]
#		tracks [
#			{
#				OPTIONAL artist (iff artistid == 1)
#				OPTIONAL duration =>
#				track => name
#				tracknum => seq
#			}
#		]
#	MOD_ADD_ARTIST PreInsert
#		artist => ArtistName
#		sortname => SortName
#		artist_only => same as sortname
#	MOD_ADD_TRACK_KV PreInsert
#		artistid => some id
#		albumid => some id
#		tracks => [
#			{
#				track => track name
#				tracknum => track number
#				artist => artist name
#				sortname => artist sortname
#				(artist + sortname are both filled in if "artistid" ==
#					VARTIST_ID; both are missing otherwise)
#			}
#		] (always exactly one track)

# %info hash needs to have the following keys defined
#  (artist (name) and sortname) or artistid                [required]
#  album name or albumid                                   [required]
#  attributes -> ref to array                              [optional]
#  forcenewalbum (defaults to no)                          [optional]
#  cdindexid and toc                                       [optional]
#  tracks -> array of hash refs:                           [required]
#    track    title                                        [required]
#    tracknum                                              [required]
#    artist or artistid                                    [MACs only]
#    sortname                                              [MACs only]
#    trmid                                                 [optional]
#    duration                                              [optional]
#    year                                                  [optional]
#  artist_only                                             [optional]
#
# Notes: If more than one album by the same artist and same album name 
#        exists, this function will attempt to fill in any missing information
#        in the first album it finds. If you want to use a specific album,
#        specify the album id, rather than the album name.
sub Insert
{
    my ($this, $info) = @_; 
    my ($ar, $al, $mar, $tr, $gu, $di, $sql);
    my ($artist, $album, $sortname, $artistid, $albumid, $trackid);
    my ($forcenewalbum, @albumtracks, $albumtrack, $track, $found);
    my ($track_artistid);

    delete $info->{artist_insertid};
    delete $info->{album_insertid};
    delete $info->{cdindexid_insertid};

    # Sanity check all the insert values
    if (!exists $info->{artist} && !exists $info->{artistid})
    {
        die "Insert failed: no artist or artistid given.\n";
    }
    if (!exists $info->{album} && 
        !exists $info->{albumid} &&
        !exists $info->{artist_only})
    {
        die "Insert failed: no album or albumid given.\n";
    }
    if (!exists $info->{tracks} &&
        !exists $info->{artist_only})
    {
        die "Insert failed: no tracks given.\n";
    }
    if (exists $info->{cdindexid} && 
        (length($info->{cdindexid}) != 28 || 
         substr($info->{cdindexid}, -1, 1) ne '-'))
    {
        die "Skipped failed: invalid cdindex id given.\n";
    }
    if (exists $info->{toc} && $info->{toc} eq '')
    {
        die "Skipped failed: invalid toc given.\n";
    }

    $forcenewalbum = (exists $info->{forcenewalbum} && $info->{forcenewalbum});
    if ($forcenewalbum && exists $info->{albumid})
    {
        die "Insert failed: you cannot force a new album and provide an albumid.\n";
    }

    $ar = Artist->new($this->{DBH});
    $mar = Artist->new($this->{DBH});
    $al = Album->new($this->{DBH});
    $tr = Track->new($this->{DBH});
    $gu = TRM->new($this->{DBH});
    $di = Discid->new($this->{DBH});

    # Try and resolve/check the artist name
    if (exists $info->{artistid})
    {
        # If we're given an artist id, load the artist and get the name
        $ar->SetId($info->{artistid});
        if (!defined $ar->LoadFromId())
        {
            die "Insert failed: Could not load artist: $info->{artistid}\n";
        }

        $artist = $ar->GetName();
        $artistid = $ar->GetId();
        $sortname = $ar->GetSortName();
    }
    else
    {
        my ($alias, $newartistid);

        if ($info->{artist} eq '')
        {
            die "Insert failed: no artist given.\n";
        }
        if (!exists $info->{sortname} || $info->{sortname} eq '')
        {
            $info->{sortname} = $info->{artist};
        }

        $artist = $info->{artist};
        $sortname = $info->{sortname};
    }

    if (!exists $info->{artist_only})
    {

        # Try and resolve/check the album name
        if (exists $info->{albumid})
        {
            # If we're given an album id, load the album and get the name
            $al->SetId($info->{albumid});
            if (!defined $al->LoadFromId())
            {
                die "Insert failed: Could not load given " .
                                 "albumid.\n";
            }
    
            $album = $al->GetName();
            $albumid = $al->GetId();
        }
        else
        {
            if ($info->{album} eq '')
            {
                die "Insert failed: No album name given.\n";
            }
    
            $album = $info->{album};
        }
    }

    #print STDERR = "  Artist: '$artist'\n";
    #print STDERR = "Sortname: '$sortname'\n";
    #print STDERR = "   Album: '$album'\n";

    # If we have no artistid, then insert the artist
    if (!defined $artistid)
    {
        $ar->SetName($artist);
        $ar->SetSortName($sortname);
        $artistid = $ar->Insert(no_alias => $info->{artist_only});
        if (!defined $artistid)
        {
            die "Insert failed: Cannot insert artist.\n";
        }
        $info->{artist_insertid} = $artistid if ($ar->GetNewInsert());
    }
    $info->{_artistid} = $artistid;

    # If we're only inserting an artist, bail now
    if (exists $info->{artist_only})
    {
        return 1;
    }

    # If we were given an albumid, make sure that the artist from
    # that album matches the artist we just inserted/looked up.
    if (defined $albumid)
    {
        # If we get to this point, we will have verified the Album by
        # loading it from disk. Check to make sure that the specified
        # album does indeed go to the correct artist.
        if ($artistid != $al->GetArtist())
        {
            die "Insert failed: Artist/Album id clash.\n";
        }
    }

    # No album id at this point means that we need to lookup/insert the album
    if (!defined $albumid)
    {
        if ($forcenewalbum)
        {
           $al->SetName($album);
           $al->SetArtist($artistid);
           if (exists $info->{attrs})
           {
               $al->SetAttributes(@{ $info->{attrs} });
           }
           $albumid = $al->Insert;
           if (!defined $albumid)
           {
               die "Insert failed: cannot insert new album.\n";
           }
           $info->{album_insertid} = $albumid if ($al->GetNewInsert());
        }
        else
        {
           my @ids;

           $al->SetArtist($artistid);
           (@ids) = $al->GetAlbumListFromName($album);
           if (scalar(@ids) == 0)
           {
               if (exists $info->{attrs})
               {
                   $al->SetAttributes(@{ $info->{attrs} });
               }
               $albumid = $al->Insert;
               if (!defined $albumid)
               {
                   die "Insert failed: cannot insert new album.\n";
               }
               $info->{album_insertid} = $albumid if ($al->GetNewInsert());
           }
           else
           {
               $albumid = $ids[0]->{mbid};
               $al->SetMBId($albumid);
               if (!defined $al->LoadFromId())
               {
                   die "Insert failed: cannot album $albumid.\n";
               }
           }
        }
    }
    $info->{_albumid} = $albumid;

    # If a valid cdindexid and toc was supplied, then insert that now
    if (exists $info->{cdindexid} && exists $info->{toc})
    {
        $di->Insert($info->{cdindexid}, $albumid, $info->{toc});
        $info->{cdindexid_insertid} = $info->{cdindexid};
    }

    # At this point $ar contains a valid loaded artist and $al contains
    # a valid loaded album

    $info->{album_complete} = 1;
    @albumtracks = $al->LoadTracks();

    my $ref = $info->{tracks};
    foreach $track (@$ref)
    {
        if (!exists $track->{track} || $track->{track} eq '')
        {
            die "Skipped Insert: Cannot insert blank track name\n";
        }
        if (!exists $track->{tracknum} || $track->{tracknum} <= 0)
        {
            die "Skipped Insert: Invalid track number\n";
        }
        if (exists $track->{trmid} && length($track->{trmid}) != 36)
        {
            die "Skipped Insert: Invalid trmid\n";
        }
        delete $track->{track_insertid};
        delete $track->{trm_insertid};
        delete $track->{artist_insertid};

        #print STDERR "name: $track->{track}\n";
        #print STDERR "num: $track->{tracknum}\n";
        #print STDERR "trm: $track->{trmid}\n" if (exists $track->{trmid});
        #print STDERR "artist: $track->{artist}\n" if (exists $track->{artist});

        $found = 0;
        foreach $albumtrack (@albumtracks)
        {
            # Check to see if the given track exists. If so, check to
            # see if a trm id was given. If it was, then insert the
            # trmid for this track.
            if ($albumtrack->GetSequence() == $track->{tracknum} &&
                $albumtrack->GetName() eq $track->{track} &&
                exists $track->{trmid} && $track->{trmid} ne '')
            {
                my $newtrm;
                
                $newtrm = $gu->Insert($track->{trmid}, $albumtrack->GetId());
                if (defined $newtrm)
                {
                    $track->{trm_insertid} = $newtrm if ($gu->GetNewInsert());
                }
                
                $found = 1;
                last;
            }
            # If a track with that tracknumber already exists, skip the insertion.
            if ($albumtrack->GetSequence() == $track->{tracknum})
            {
                $info->{album_complete} = 0;
                $found = 1;
                last;
            }
        }
        if ($found)
        {
            #print STDERR ("Track found. Skipping.\n\n");
            next;
        }

        # Ok, the track passes all the tests. Insert the track.
        $tr->SetName($track->{track});
        $tr->SetSequence($track->{tracknum});
        if (exists $track->{year} && $track->{year} != 0)
        {
            $tr->SetYear($track->{year});
        }
        if (exists $track->{duration} && $track->{duration} != 0)
        {
            $tr->SetLength($track->{duration});
        }

        # Check to see if this track has an artist that needs to get
        # looked up/inserted.
        undef $track_artistid;
        if (exists $track->{artist} && $artistid == &ModDefs::VARTIST_ID)
        {
            if ($track->{artist} eq '')
            {
                die "Track Insert failed: no artist given.\n";
            }
            if (!exists $track->{sortname} || $track->{sortname} eq '')
            {
                $track->{sortname} = $track->{artist};
            }
        
            # Load/insert artist
            $ar->SetName($track->{artist});
            $ar->SetSortName($track->{sortname});
            $track_artistid = $ar->Insert();
            if (!defined $track_artistid)
            {
                die "Track Insert failed: Cannot insert artist.\n";
            }
            if ($ar->GetNewInsert())
            {
                #print STDERR "Inserted artist: $track_artistid\n";
                $track->{artist_insertid} = $track_artistid 
            }
        }
        if (exists $track->{artistid} && $artistid == &ModDefs::VARTIST_ID)
        {
            $ar->SetId($track->{artistid});
            if (!defined $ar->LoadFromId())
            {
                die "Track Insert failed: Could not load artist: $info->{artistid}\n";
            }
            $track_artistid = $track->{artistid};
        }

        # Now insert the track. Make sure to check what kind of track it is...
        if ($artistid != &ModDefs::VARTIST_ID)
        {
            $trackid = $tr->Insert($al, $ar);
        }
        else
        {
            $mar->SetId($track_artistid);
            $trackid = $tr->Insert($al, $mar);
            $track->{track_insertid} = $trackid if ($tr->GetNewInsert());
        }
        if (!defined $trackid)
        {
            die "Insert failed: Cannot insert track.\n";
        }
        $track->{track_insertid} = $trackid;

        # The track has been inserted. Now insert the TRM if there is one
        if (exists $track->{trmid} && $track->{trmid} ne '')
        {
            my $newtrm = $gu->Insert($track->{trmid}, $trackid);
            if (defined $newtrm)
            {
                $track->{trm_insertid} = $newtrm if ($gu->GetNewInsert());
            }
        }
    }

    return 1;
}

# Called by FreeDB->InsertForModeration and cdi/done.html
# This inserts a mod of type MOD_ADD_ALBUM, which in turn calls
# $insert->Insert (above).

sub InsertAlbumModeration
{
    my ($this, $new, $moderator, $privs, $artist) = @_;
    my $sql = Sql->new($this->{DBH});

	# TODO: for now, the $new passed in is still the packed string
	# (key=value\nkey=value\n etc).  Here we parse that back into hash form
	# and pass it into the MOD_ADD_ALBUM handler.  Eventually we'll invent a
	# new named-arguments convention and pass a hash like that, instead of
	# passing packed strings.
	my %opts = (
		map { split /=/, $_, 2 } grep /\S/, split /\n/, $new
	);

    my ($artistid, $albumid, $mods) = eval
    {
       $sql->Begin;

		my @mods = Moderation->InsertModeration(
			DBH	=> $this->{DBH},
			uid	=> $moderator || &ModDefs::ANON_MODERATOR,
			privs => $privs || 0,
			type => &ModDefs::MOD_ADD_ALBUM,
			#
			%opts,
			artist => $artist,
		);

		(my $mod) = grep { $_->Type == &ModDefs::MOD_ADD_ALBUM } @mods
			or die;
          
		$sql->Commit;

        ($mod->GetArtist, $mod->GetRowId, \@mods);
    };

    if ($@)
    {
		my $err = $@;
		$err = eval { $err->GetError } if ref $err;
		$this->{error} = $err;
		$sql->Rollback;
		return;
    }

    ($artistid, $albumid, $mods);
}

1;
