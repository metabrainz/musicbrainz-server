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

use strict;

package Insert;

use ModDefs qw( VARTIST_ID DARTIST_ID ANON_MODERATOR MODBOT_MODERATOR MOD_ADD_RELEASE );

sub new
{
    my ($type, $dbh) = @_;

	bless {
		dbh	=> $dbh,
	}, ref($type) || $type;
}

sub dbh
{
    my $self = shift;
    if (@_) { $self->{dbh} = shift; }
    return $self->{dbh};
}  

sub GetError
{
    my ($this) = @_;

    return $this->{error};
}

sub Insert
{
    my $self = shift;

	require DebugLog;
	if (my $d = DebugLog->open)
	{
		$d->stamp("Insert->Insert");
		$d->dumper([\@_], ['*_in']);
		$d->close;
	}

	my $ok = $self->_Insert(@_);

	require DebugLog;
	if (my $d = DebugLog->open)
	{
		$d->stamp("Insert->Insert");
		$d->dumper([\@_], ['*_out']);
		$d->close;
	}

	$ok;
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
#				puid => $PUID
#			}
#		] (always exactly one track)
#
#	MOD_ADD_RELEASE PreInsert
#		EITHER artist+sortname OR artistid
#		album => name
#		OPTIONAL cdindexid => ..., toc => ...
#		forcenewalbum => 1
#		attrs => [ possibly empty list of attrs ]
#		tracks => [
#			{
#				OPTIONAL artist (iff artistid == 1)
#				OPTIONAL duration =>
#				track => name
#				tracknum => seq
#			}
#		]
#		languageid => id
#		scriptid => id
#		releases => [
#			{
#				year => year, numeric, YYYY
#				OPTIONAL month => number of month
#				OPTIONAL day => number of day
#				country => country-id (not ISO code)
#			}
#		]
#
#	MOD_ADD_ARTIST PreInsert
#		artist => ArtistName
#		sortname => SortName
#		type  => ArtistType
#		OPTIONAL begindate => date-str
#		OPTIONAL enddate => date-str
#		OPTIONAL resolution => str
#		OPTIONAL mbid => guid
#		artist_only => 1
#
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
#  artist_type                                             [optional]
#  artist_resolution                                       [optional]
#  artist_begindate                                        [optional]
#  artist_enddate                                          [optional]
#  album name or albumid                                   [required]
#  attributes -> ref to array                              [optional]
#  languageid                                              [optional]
#  scriptid                                                [optional]
#  forcenewalbum (defaults to no)                          [optional]
#  cdindexid and toc                                       [optional]
#  tracks -> array of hash refs:                           [required]
#    track    title                                        [required]
#    tracknum                                              [required]
#    artist or artistid                                    [MACs only]
#    sortname                                              [MACs only]
#    puid                                                  [optional]
#    duration                                              [optional]
#    year                                                  [optional]
#  releases -> array of hash refs:                         [required]
#    year                                                  [required]
#    month                                                 [optional]
#    day                                                   [optional]
#    country                                               [required]
#  artist_only                                             [optional]
#
# Notes: If more than one album by the same artist and same album name 
#        exists, this function will attempt to fill in any missing information
#        in the first album it finds. If you want to use a specific album,
#        specify the album id, rather than the album name.
sub _Insert
{
    my ($this, $info) = @_; 

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

    my $forcenewalbum = $info->{forcenewalbum};
    if ($forcenewalbum && exists $info->{albumid})
    {
        die "Insert failed: you cannot force a new album and provide an albumid.\n";
    }

	require MusicBrainz::Server::Artist;
    my $ar = MusicBrainz::Server::Artist->new($this->dbh);
    my $mar = MusicBrainz::Server::Artist->new($this->dbh);
	require MusicBrainz::Server::Release;
    my $al = MusicBrainz::Server::Release->new($this->dbh);
	require MusicBrainz::Server::Track;
    my $tr = MusicBrainz::Server::Track->new($this->dbh);
	require MusicBrainz::Server::PUID;
    my $puid = MusicBrainz::Server::PUID->new($this->dbh);
	require MusicBrainz::Server::ReleaseEvent;
	my $rel = MusicBrainz::Server::ReleaseEvent->new($this->dbh);

	my $artist;
	my $artistid;
	my $sortname;
	my $artist_type;
	my $artist_resolution;
	my $artist_begindate;
	my $artist_enddate;

    # Try and resolve/check the artist name
    if (exists $info->{artistid})
    {
        # If we're given an artist id, load the artist and get the name
        $ar->id($info->{artistid});
        if (!defined $ar->LoadFromId())
        {
            die "Insert failed: Could not load artist: $info->{artistid}\n";
        }

        $artist = $ar->name();
        $artistid = $ar->id();
        $sortname = $ar->sort_name();
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
		$artist_type = $info->{artist_type};
		$artist_resolution = $info->{artist_resolution};
		$artist_begindate = $info->{artist_begindate};
		$artist_enddate = $info->{artist_enddate};
    }

	my $albumid;
	my $album;

    if (!exists $info->{artist_only})
    {

        # Try and resolve/check the album name
        if (exists $info->{albumid})
        {
            # If we're given an album id, load the album and get the name
            $al->id($info->{albumid});
            if (!defined $al->LoadFromId())
            {
                die "Insert failed: Could not load given albumid.\n";
            }
    
            $album = $al->name();
            $albumid = $al->id();
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
        $ar->name($artist);
        $ar->sort_name($sortname);
		$ar->type($artist_type);
		$ar->resolution($artist_resolution);
		$ar->begin_date($artist_begindate);
		$ar->end_date($artist_enddate);
        $artistid = $ar->Insert(no_alias => $info->{artist_only}, mbid => $info->{artist_mbid});
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
        if ($artistid != $al->artist())
        {
            #die "Insert failed: Artist/Album id clash.\n";
        }
    }

	my $language = $info->{languageid};
	my $script = $info->{scriptid};

	# Check if we have a vaild language id. If we don't discard it.
	if ($language)
	{
		require MusicBrainz::Server::Language;
		my $l = MusicBrainz::Server::Language->newFromId(
													$this->{dbh}, $language);

		$language = undef unless defined $l;
	}

	# Check if we have a vaild script id. Again, if we don't discard it.
	if ($script)
	{
		require MusicBrainz::Server::Script;
		my $s = MusicBrainz::Server::Script->newFromId(
													$this->{dbh}, $script);

		$script = undef unless defined $s;
	}

    # No album id at this point means that we need to lookup/insert the album
    if (!defined $albumid)
    {
        if ($forcenewalbum)
        {
           $al->name($album);
           $al->artist($artistid);
           if (exists $info->{attrs})
           {
               $al->attributes(@{ $info->{attrs} });
           }
           $al->language_id($language) if $language;
           $al->script_id($script) if $script;
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

           $al->artist($artistid);
           (@ids) = $al->GetAlbumListFromName($album);
           if (scalar(@ids) == 0)
           {
               if (exists $info->{attrs})
               {
                   $al->attributes(@{ $info->{attrs} });
               }
               $al->language_id($language) if $language;
               $al->script_id($script) if $script;
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
               $al->mbid($albumid);
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
		require MusicBrainz::Server::ReleaseCDTOC;
		MusicBrainz::Server::ReleaseCDTOC->Insert($this->{dbh}, $albumid, $info->{toc});
        $info->{cdindexid_insertid} = $info->{cdindexid};
    }

    # At this point $ar contains a valid loaded artist and $al contains
    # a valid loaded album

    $info->{album_complete} = 1;
    my @albumtracks = $al->LoadTracks();

    my $ref = $info->{tracks};
TRACK:
    for my $track (@$ref)
    {
        if (!exists $track->{track} || $track->{track} eq '')
        {
            die "Skipped Insert: Cannot insert blank track name\n";
        }
        if (!exists $track->{tracknum} || $track->{tracknum} <= 0)
        {
            die "Skipped Insert: Invalid track number\n";
        }
        if (exists $track->{puid} && length($track->{puid}) != 36)
        {
            die "Skipped Insert: Invalid puid\n";
        }
        delete $track->{track_insertid};
        delete $track->{puid_insertid};
        delete $track->{artist_insertid};
        delete $track->{track_artistid};

        #print STDERR "name: $track->{track}\n";
        #print STDERR "num: $track->{tracknum}\n";
        #print STDERR "artist: $track->{artist}\n" if (exists $track->{artist});

        for my $albumtrack (@albumtracks)
        {
            # Check to see if the given track exists. If so, check to
            # see if a puid was given. If it was, then insert the
            # puid for this track.
            if ($albumtrack->sequence() == $track->{tracknum} &&
                $albumtrack->name() eq $track->{track} &&
                exists $track->{puid} && $track->{puid} ne '')
            {
                my $newpuid;

                $newpuid = $puid->Insert($track->{puid}, $albumtrack->id());
                if (defined $newpuid)
                {
                    $track->{puid_insertid} = $newpuid if ($puid->GetNewInsert());
                }

                next TRACK;
            }
            # If a track with that tracknumber already exists, skip the insertion.
            if ($albumtrack->sequence() == $track->{tracknum})
            {
                $info->{album_complete} = 0;
				next TRACK;
            }
        }

        # Ok, the track passes all the tests. Insert the track.
        $tr->name($track->{track});
        $tr->sequence($track->{tracknum});
        if (exists $track->{year} && $track->{year} != 0)
        {
            $tr->SetYear($track->{year});
        }
        if (exists $track->{duration})
        {
            $tr->length($track->{duration});
        }

        # Check to see if this track has an artist that needs to get
        # looked up/inserted.
        my $track_insertartistid;
        if (exists $track->{artist} && $artistid == VARTIST_ID)
        {
            if ($track->{artist} eq "")
            {
                die "Track Insert failed: no artist given.\n";
            }
			$track->{sortname} = $track->{artist}
				if (!exists $track->{sortname} || $track->{sortname} eq "");        
           
            # Load/insert artist
            $ar->name($track->{artist});
            $ar->sort_name($track->{sortname});
            $ar->type(0);
            $ar->resolution("");
            $ar->begin_date("");
            $ar->end_date("");
            $track_insertartistid = $ar->Insert();
            if (!defined $track_insertartistid)
            {
                die "Track Insert failed: Cannot insert artist.\n";
            }
            if ($ar->GetNewInsert())
            {
                #print STDERR "Inserted artist: $track_insertartistid\n";
                $track->{artist_insertid} = $track_insertartistid 
            }
        }
        
		my $trackid;        
		my $track_artistid = $track->{artistid};
		
        # we allow releases attributed to other artists
        # than VARTIST_ID to have different track artists. they
        # will have a artistid != track->artistid, but 
        # a track->artistid not IN (0,VARTIST_ID, DARTIST_ID)
        # -- (keschte)
        if (exists $track->{artistid} &&
        	$track_artistid > 0 and
        	$track_artistid != VARTIST_ID and
        	$track_artistid != DARTIST_ID) 
        {
            $ar->id($track_artistid);
            if (!defined $ar->LoadFromId())
            {
                die "Track Insert failed: Could not load artist: $info->{artistid}\n";
            }

			# insert track using the verified track artist            
            $mar->id($track_artistid);
            $trackid = $tr->Insert($al, $mar);
            $track->{track_insertid} = $trackid if ($tr->GetNewInsert());
        }
        else
        {
        	
			# insert track for release artist.
			$trackid = $tr->Insert($al, $ar);        
       }
        if (!defined $trackid)
        {
            die "Insert failed: Cannot insert track.\n";
        }
        $track->{track_insertid} = $trackid;

        #print STDERR "Inserted track: $trackid, artist: $track_artistid\n";

        # Now insert the PUID if there is one
        if (exists $track->{puid} && $track->{puid} ne '')
        {
            my $newpuid = $puid->Insert($track->{puid}, $trackid);
            if (defined $newpuid)
            {
                $track->{puid_insertid} = $newpuid if ($puid->GetNewInsert());
            }
        }
    }

	for my $release ( @{ $info->{releases} } )
	{
		delete $release->{release_insertid};

		my @ymd = MusicBrainz::Server::Validation::IsValidDateOrEmpty(
					$release->{year}, $release->{month}, $release->{day})
					or die "Skipped Insert: Invalid release date\n";

		if (!exists $release->{country} || $release->{country} eq '')
		{
			die "Skipped Insert: Release country is required\n";
		}

                my $label = MusicBrainz::Server::Label->new($this->dbh);
                $label->id($release->{label});

		$rel->release($albumid);
		$rel->date(@ymd);
		$rel->country($release->{country});
		$rel->label($label);
		$rel->cat_no($release->{catno});
		$rel->barcode($release->{barcode});
		$rel->format($release->{format});
		$rel->InsertSelf();

		$release->{release_insertid} = $rel->id();
	}

    return 1;
}

# Called by FreeDB->InsertForModeration and cdi/done.html
# This inserts a mod of type MOD_ADD_RELEASE, which in turn calls
# $insert->Insert (above).

sub InsertAlbumModeration
{
    my ($this, $new, $moderator, $privs, $artist) = @_;
	require Sql;
    my $sql = Sql->new($this->dbh);

	# TODO: for now, the $new passed in is still the packed string
	# (key=value\nkey=value\n etc).  Here we parse that back into hash form
	# and pass it into the MOD_ADD_RELEASE handler.  Eventually we'll invent a
	# new named-arguments convention and pass a hash like that, instead of
	# passing packed strings.
	my %opts = (
		map { split /=/, $_, 2 } grep /\S/, split /\n/, $new
	);

    my ($artistid, $albumid, $mods) = eval
    {
		require Moderation;
		# FIXME "artist" is undef.  Does this matter?
		my @mods = Moderation->InsertModeration(
			dbh	=> $this->{dbh},
			uid	=> $moderator || ANON_MODERATOR,
			privs => $privs || 0,
			type => MOD_ADD_RELEASE,
			#
			%opts,
			artist => $artist,
		);

		(my $mod) = grep { $_->Type == MOD_ADD_RELEASE } @mods
			or die;

		$mod->InsertNote(
			MODBOT_MODERATOR,
			"Imported from FreeDB $opts{FreedbCat}/$opts{FreedbId}",
			nosend => 1,
		)	if defined $opts{"FreedbId"}
			and defined $opts{"FreedbCat"};

        ($mod->artist, $mod->row_id, \@mods);
    };

    if ($@)
    {
		my $err = $@;
		$this->{error} = $err;
		return;
    }

    ($artistid, $albumid, $mods);
}

1;
