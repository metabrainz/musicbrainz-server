#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use Artist;
use Album;
use Track;
use Alias;
use GUID;
use Diskid;

use Data::Dumper;

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

# %info hash needs to have the following keys defined
#  (artist (name) and sortname) or artistid                [required]
#  album name or albumid                                   [required]
#  skipmod (defaults to no)                                [optional]
#  forcenewalbum (defaults to no)                          [optional]
#  cdindexid and toc                                       [optional]
#  tracks -> array of hash refs:                           [required]
#    track    title                                        [required]
#    tracknum                                              [required]
#    trmid                                                 [optional]
#    duration                                              [optional]
#    year                                                  [optional]
#
# Notes: If more than one album by the same artist and same album name 
#        exists, this function will attempt to fill in any missing information
#        in the first album it finds. If you want to use a specific album,
#        specify the album id, rather than the album name.
sub Insert
{
    my ($this, $info) = @_; 
    my ($ar, $al, $tr, $gu, $di);
    my ($artist, $album, $sortname, $artistid, $albumid, $trackid);
    my ($forcenewalbum, @albumtracks, $albumtrack, $track, $found);

    # Sanity check all the insert values
    if (!exists $info->{artist} && !exists $info->{artistid})
    {
        $this->{error} = "Insert failed: no artist or artistid given.\n";
        return undef;
    }
    if (!exists $info->{album} && !exists $info->{albumid})
    {
        $this->{error} = "Insert failed: no album or albumid given.\n";
        return undef;
    }
    if (!exists $info->{tracks})
    {
        $this->{error} = "Insert failed: no tracks given.\n";
        return undef;
    }
    if (exists $info->{cdindexid} && 
        (length($info->{cdindexid}) != 28 || 
         substr($info->{cdindexid}, -1, 1) ne '-'))
    {
        $this->{error} = "Skipped failed: invalid cdindex id given.\n";
        delete $info->{cdindexid};
    }
    if (exists $info->{toc} && $info->{toc} eq '')
    {
        $this->{error} = "Skipped failed: invalid toc given.\n";
        delete $info->{toc};
    }

    $forcenewalbum = (exists $info->{forcenewalbum} && $info->{forcenewalbum});
    if ($forcenewalbum && exists $info->{albumid})
    {
        $this->{error} = "Insert failed: you cannot force a new album and ";
        $this->{error} = "provide an albumid.\n";
        return undef;
    }

    $ar = Artist->new($this->{DBH});
    $al = Album->new($this->{DBH});
    $tr = Track->new($this->{DBH});
    $gu = GUID->new($this->{DBH});
    $di = Diskid->new($this->{DBH});

    # Try and resolve/check the artist name
    if (exists $info->{artistid})
    {
        # If we're given an artist id, load the artist and get the name
        $ar->SetId($info->{artistid});
        if (!defined $ar->LoadFromId())
        {
            $this->{error} = "Insert failed: Could not load artist: $info->{artistid}\n";
            return undef;
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
            $this->{error} = "Insert failed: no artist given.\n";
            return undef;
        }
        if (!exists $info->{sortname} || $info->{sortname} eq '')
        {
            $info->{sortname} = $info->{artist};
        }

        $alias = Alias->new($this->{DBH});
        $alias->{table} = "ArtistAlias";
        $newartistid = $alias->Resolve($info->{artist});
        if (defined $newartistid)
        {
           $ar->SetId($newartistid);
           if (!defined $ar->LoadFromId())
           {
               $this->{error} = "Insert failed: Could not load aliased " .
                                "artist $newartistid.\n";
           }

           $artistid = $newartistid;
           $artist = $ar->GetName();
           $sortname = $ar->GetSortName();
        }
        else
        {
           $artist = $info->{artist};
           $sortname = $info->{sortname};
        }
    }

    # Try and resolve/check the album name
    if (exists $info->{albumid})
    {
        # If we're given an album id, load the album and get the name
        $al->SetId($info->{albumid});
        if (!defined $al->LoadFromId())
        {
            $this->{error} = "Insert failed: Could not load given albumid.\n";
            return undef;
        }

        $album = $al->GetName();
        $albumid = $al->GetId();
    }
    else
    {
        if ($info->{album} eq '')
        {
            $this->{error} = "Insert failed: No album name given.\n";
            return undef;
        }

        $album = $info->{album};
    }

    #print STDERR = "  Artist: '$artist'\n";
    #print STDERR = "Sortname: '$sortname'\n";
    #print STDERR = "   Album: '$album'\n";

    # TODO: BEGIN a DB transaction here

    # If we have no artistid, then insert the artist
    if (!defined $artistid)
    {
        $ar->SetName($artist);
        $ar->SetSortName($sortname);
        $artistid = $ar->Insert();
        if (!defined $artistid)
        {
            $this->{error} = "Insert failed: Cannot insert artist.\n";
            return undef;
        }
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
            $this->{error} = "Insert failed: Artist/Album id clash.\n";
            return undef;
        }
    }


    # No album id at this point means that we need to lookup/insert the album
    if (!defined $albumid)
    {
        if ($forcenewalbum)
        {
           $al->SetName($album);
           $al->SetArtist($artistid);
           $albumid = $al->Insert;
           if (!defined $albumid)
           {
               $this->{error} = "Insert failed: cannot insert new album.\n";
               return undef;
           }
        }
        else
        {
           $al->SetName($album);
           $al->SetArtist($artistid);
           if (!defined $al->LoadFromName)
           {
               $albumid = $al->Insert;
               if (!defined $albumid)
               {
                   $this->{error} = "Insert failed: cannot insert new album.\n";
                   return undef;
               }
           }
           else
           {
               $albumid = $al->GetId();
           }
        }
    }

    # If a valid cdindexid and toc was supplied, then insert that now
    if (exists $info->{cdindexid} && exists $info->{toc})
    {
        $di->Insert($info->{cdindexid}, $albumid, $info->{toc});
    }

    # At this point $ar contains a valid loaded artist and $al contains
    # a valid loaded album

    @albumtracks = $al->LoadTracks();

    my $ref = $info->{tracks};
    foreach $track (@$ref)
    {
        if (!exists $track->{track} || $track->{track} eq '')
        {
            $this->{error} = "Skipped Insert: Cannot insert blank tack name\n";
            next;
        }
        if (!exists $track->{tracknum} || $track->{tracknum} <= 0)
        {
            $this->{error} = "Skipped Insert: Invalid track number\n";
            next;
        }
        if (exists $track->{trmid} && length($track->{trmid}) != 36)
        {
            $this->{error} = "Skipped Insert: Invalid trmid\n";
            delete $track->{trmid};
        }
        #print STDERR "$track->{track}\n";
        #print STDERR "$track->{tracknum}\n";
        #print STDERR "$track->{trmid}\n" if (exists $track->{trmid});

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
                $gu->Insert($track->{trmid}, $albumtrack->GetId());
                
                #$print STDERR "Insert GUID.\n";

                $found = 1;
                last;
            }
            # If a track with that tracknumber already exists, skip
            # the insertion.
            if ($albumtrack->GetSequence() == $track->{tracknum})
            {
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
            $tr->SetDuration($track->{duration});
        }

        #if (exists $track->{artistid}

        $trackid = $tr->Insert($al, $ar);
        if (!defined $trackid)
        {
            $this->{error} = "Insert failed: Cannot insert track.\n";
            last;
        }

        # The track has been inserted. Now insert the GUID if there is one
        if (exists $track->{trmid} && $track->{trmid} ne '')
        {
            $gu->Insert($track->{trmid}, $trackid);
        }

        #print STDERR "Inserted track $track->{tracknum} $track->{track}.\n\n";
    }

    # TODO: Commit a transaction here

    return 1;
}

