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

package Moderation;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Carp;
use DBDefs;
use ModDefs ':all';
use MusicBrainz::Server::Validation qw( unaccent );
use Encode qw( encode decode );
use utf8;

# Load all the moderation handlers (sorted please)
require MusicBrainz::Server::Moderation::MOD_ADD_RELEASE;
require MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_ANNOTATION;
require MusicBrainz::Server::Moderation::MOD_ADD_ARTIST;
require MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_ADD_ARTIST_ANNOTATION;
require MusicBrainz::Server::Moderation::MOD_ADD_TRACK_ANNOTATION;
require MusicBrainz::Server::Moderation::MOD_ADD_DISCID;
require MusicBrainz::Server::Moderation::MOD_ADD_LABEL;
require MusicBrainz::Server::Moderation::MOD_ADD_LABELALIAS;
require MusicBrainz::Server::Moderation::MOD_ADD_LABEL_ANNOTATION;
require MusicBrainz::Server::Moderation::MOD_ADD_LINK;
require MusicBrainz::Server::Moderation::MOD_ADD_LINK_ATTR;
require MusicBrainz::Server::Moderation::MOD_ADD_LINK_TYPE;
require MusicBrainz::Server::Moderation::MOD_ADD_PUIDS;
require MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_EVENTS;
require MusicBrainz::Server::Moderation::MOD_ADD_TRACK;
require MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV;
require MusicBrainz::Server::Moderation::MOD_CHANGE_ARTIST_QUALITY;
require MusicBrainz::Server::Moderation::MOD_CHANGE_RELEASE_QUALITY;
require MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST;
require MusicBrainz::Server::Moderation::MOD_CHANGE_WIKIDOC;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_LANGUAGE;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_ATTRS;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_NAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTIST;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_LABEL;
require MusicBrainz::Server::Moderation::MOD_EDIT_LABELALIAS;
require MusicBrainz::Server::Moderation::MOD_EDIT_LINK;
require MusicBrainz::Server::Moderation::MOD_EDIT_LINK_ATTR;
require MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS_OLD;
require MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM;
require MusicBrainz::Server::Moderation::MOD_EDIT_TRACKTIME;
require MusicBrainz::Server::Moderation::MOD_EDIT_URL;
require MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC;
require MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE;
require MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE_MAC;
require MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST;
require MusicBrainz::Server::Moderation::MOD_MERGE_LABEL;
# require MusicBrainz::Server::Moderation::MOD_MERGE_LINK_TYPE; -- not implemented
require MusicBrainz::Server::Moderation::MOD_MOVE_RELEASE;
require MusicBrainz::Server::Moderation::MOD_MOVE_DISCID;
require MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE;
require MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASES;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID;
require MusicBrainz::Server::Moderation::MOD_REMOVE_LABEL;
require MusicBrainz::Server::Moderation::MOD_REMOVE_LABELALIAS;
require MusicBrainz::Server::Moderation::MOD_REMOVE_LINK;
require MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_ATTR;
require MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_TYPE;
require MusicBrainz::Server::Moderation::MOD_REMOVE_PUID;
require MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE_EVENTS;
require MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK;
require MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC;
require MusicBrainz::Server::Moderation::MOD_SET_RELEASE_DURATIONS;

# The following three hashes define the various edit/vote semantics for the three editing levels
my @EditLevelDefs =
(
	{   # low quality
		MOD_EDIT_ARTISTNAME		     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1, 
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME::Name() },  
		MOD_EDIT_ARTISTSORTNAME  	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME::Name() },  
		MOD_EDIT_RELEASE_NAME			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_NAME::Name() },  
		MOD_EDIT_TRACKNAME			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME::Name() },  
		MOD_EDIT_TRACKNUM			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM::Name() },  
		MOD_MERGE_ARTIST			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST::Name() },  
		MOD_ADD_TRACK				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK::Name() },  
		MOD_MOVE_RELEASE				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_RELEASE::Name() },  
		MOD_SAC_TO_MAC				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC::Name() },  
		MOD_CHANGE_TRACK_ARTIST	     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST::Name() },  
		MOD_REMOVE_TRACK			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK::Name() },  
		MOD_REMOVE_RELEASE			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE::Name() },  
		MOD_MAC_TO_SAC				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC::Name() },  
		MOD_REMOVE_ARTISTALIAS		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTISTALIAS::Name() },  
		MOD_ADD_ARTISTALIAS		     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS::Name() },  
		MOD_ADD_RELEASE				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE::Name() },  
		MOD_ADD_ARTIST				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST::Name() },  
		MOD_ADD_TRACK_KV			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV::Name() },  
		MOD_REMOVE_ARTIST			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST::Name() },  
		MOD_REMOVE_DISCID			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID::Name() },  
		MOD_MOVE_DISCID			     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_DISCID::Name() },  
		MOD_MERGE_RELEASE			     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE::Name() },  
		MOD_REMOVE_RELEASES			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASES::Name() },  
		MOD_MERGE_RELEASE_MAC	    	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE_MAC::Name() },  
		MOD_EDIT_RELEASE_ATTRS	    	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_ATTRS::Name() },  
		MOD_EDIT_ARTISTALIAS		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS::Name() },  
		MOD_EDIT_RELEASE_EVENTS_OLD			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS_OLD::Name() },  
		MOD_ADD_ARTIST_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST_ANNOTATION::Name() },  
		MOD_ADD_RELEASE_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_ANNOTATION::Name() },  
		MOD_ADD_TRACK_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_ANNOTATION::Name() },  
		MOD_ADD_DISCID				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_DISCID::Name() },  
		MOD_ADD_LINK				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK::Name() },  
		MOD_EDIT_LINK				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK::Name() },  
		MOD_REMOVE_LINK			     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK::Name() },  
		MOD_ADD_LINK_TYPE			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_TYPE::Name() },  
		MOD_EDIT_LINK_TYPE			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE::Name() },  
		MOD_REMOVE_LINK_TYPE		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_TYPE::Name() },  
		MOD_EDIT_ARTIST			     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTIST::Name() },  
		MOD_ADD_LINK_ATTR			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_ATTR::Name() },  
		MOD_EDIT_LINK_ATTR			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_ATTR::Name() },  
		MOD_REMOVE_LINK_ATTR		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_ATTR::Name() },  
		MOD_EDIT_RELEASE_LANGUAGE	     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_LANGUAGE::Name() },  
		MOD_EDIT_TRACKTIME			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKTIME::Name() },  
		MOD_REMOVE_PUID			     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_PUID::Name() },  
		MOD_ADD_PUIDS				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_PUIDS::Name() },  
		MOD_CHANGE_WIKIDOC			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_WIKIDOC::Name() },  
		MOD_ADD_RELEASE_EVENTS		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_EVENTS::Name() },  
		MOD_EDIT_RELEASE_EVENTS		 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS::Name() },  
		MOD_REMOVE_RELEASE_EVENTS	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE_EVENTS::Name() },  
		MOD_SET_RELEASE_DURATIONS	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SET_RELEASE_DURATIONS::Name() },  
		MOD_EDIT_URL				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_URL::Name() },  
		MOD_ADD_LABEL				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL::Name() },  
		MOD_ADD_LABEL_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL_ANNOTATION::Name() },  
		MOD_ADD_LABELALIAS			 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABELALIAS::Name() },  
		MOD_REMOVE_LABEL        	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABEL::Name() },  
		MOD_REMOVE_LABELALIAS   	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABELALIAS::Name() },  
		MOD_EDIT_LABEL				 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABEL::Name() },  
		MOD_MERGE_LABEL         	 ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_LABEL::Name() },  
		MOD_EDIT_LABELALIAS		     ."" => { duration => 4, votes => 1, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABELALIAS::Name() },  
	},
	{   # Normal edit level
		MOD_EDIT_ARTISTNAME		     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME::Name() },  
		MOD_EDIT_ARTISTSORTNAME  	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME::Name() },  
		MOD_EDIT_RELEASE_NAME			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_NAME::Name() },  
		MOD_EDIT_TRACKNAME			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME::Name() },  
		MOD_EDIT_TRACKNUM			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM::Name() },  
		MOD_MERGE_ARTIST			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST::Name() },  
		MOD_ADD_TRACK				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK::Name() },  
		MOD_MOVE_RELEASE				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_RELEASE::Name() },  
		MOD_SAC_TO_MAC				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC::Name() },  
		MOD_CHANGE_TRACK_ARTIST	     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST::Name() },  
		MOD_REMOVE_TRACK			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK::Name() },  
		MOD_REMOVE_RELEASE			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE::Name() },  
		MOD_MAC_TO_SAC				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC::Name() },  
		MOD_REMOVE_ARTISTALIAS		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTISTALIAS::Name() },  
		MOD_ADD_ARTISTALIAS		     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS::Name() },  
		MOD_ADD_RELEASE				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE::Name() },  
		MOD_ADD_ARTIST				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST::Name() },  
		MOD_ADD_TRACK_KV			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV::Name() },  
		MOD_REMOVE_ARTIST			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST::Name() },  
		MOD_REMOVE_DISCID			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID::Name() },  
		MOD_MOVE_DISCID			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_DISCID::Name() },  
		MOD_MERGE_RELEASE			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE::Name() },  
		MOD_REMOVE_RELEASES			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASES::Name() },  
		MOD_MERGE_RELEASE_MAC	    	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE_MAC::Name() },  
		MOD_EDIT_RELEASE_ATTRS	    	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_ATTRS::Name() },  
		MOD_EDIT_ARTISTALIAS		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS::Name() },  
		MOD_EDIT_RELEASE_EVENTS_OLD			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS_OLD::Name() },  
		MOD_ADD_ARTIST_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST_ANNOTATION::Name() },  
		MOD_ADD_RELEASE_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_ANNOTATION::Name() },  
		MOD_ADD_TRACK_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_ANNOTATION::Name() },  
		MOD_ADD_DISCID				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_DISCID::Name() },  
		MOD_ADD_LINK				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK::Name() },  
		MOD_EDIT_LINK				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK::Name() },  
		MOD_REMOVE_LINK			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK::Name() },  
		MOD_ADD_LINK_TYPE			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_TYPE::Name() },  
		MOD_EDIT_LINK_TYPE			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE::Name() },  
		MOD_REMOVE_LINK_TYPE		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_TYPE::Name() },  
		MOD_EDIT_ARTIST			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTIST::Name() },  
		MOD_ADD_LINK_ATTR			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_ATTR::Name() },  
		MOD_EDIT_LINK_ATTR			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_ATTR::Name() },  
		MOD_REMOVE_LINK_ATTR		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_ATTR::Name() },  
		MOD_EDIT_RELEASE_LANGUAGE	     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_LANGUAGE::Name() },  
		MOD_EDIT_TRACKTIME			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKTIME::Name() },  
		MOD_REMOVE_PUID			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_PUID::Name() },  
		MOD_ADD_PUIDS				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_PUIDS::Name() },  
		MOD_CHANGE_WIKIDOC			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_WIKIDOC::Name() },  
		MOD_ADD_RELEASE_EVENTS		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_EVENTS::Name() },  
		MOD_EDIT_RELEASE_EVENTS		 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS::Name() },  
		MOD_REMOVE_RELEASE_EVENTS	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE_EVENTS::Name() },  
		MOD_SET_RELEASE_DURATIONS	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SET_RELEASE_DURATIONS::Name() },  
		MOD_EDIT_URL				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_URL::Name() },  
		MOD_ADD_LABEL				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL::Name() },  
		MOD_ADD_LABEL_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL_ANNOTATION::Name() },  
		MOD_ADD_LABELALIAS			 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABELALIAS::Name() },  
		MOD_REMOVE_LABEL        	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABEL::Name() },  
		MOD_REMOVE_LABELALIAS   	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABELALIAS::Name() },  
		MOD_EDIT_LABEL				 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABEL::Name() },  
		MOD_MERGE_LABEL         	 ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_LABEL::Name() },  
		MOD_EDIT_LABELALIAS		    ."" => { duration => 14, votes => 3, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABELALIAS::Name() },  
	},
	{   # high edit level
		MOD_EDIT_ARTISTNAME		     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME::Name() },  
		MOD_EDIT_ARTISTSORTNAME  	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME::Name() },  
		MOD_EDIT_RELEASE_NAME			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_NAME::Name() },  
		MOD_EDIT_TRACKNAME			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME::Name() },  
		MOD_EDIT_TRACKNUM			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM::Name() },  
		MOD_MERGE_ARTIST			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST::Name() },  
		MOD_ADD_TRACK				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK::Name() },  
		MOD_MOVE_RELEASE				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_RELEASE::Name() },  
		MOD_SAC_TO_MAC				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC::Name() },  
		MOD_CHANGE_TRACK_ARTIST	     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST::Name() },  
		MOD_REMOVE_TRACK			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK::Name() },  
		MOD_REMOVE_RELEASE			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE::Name() },  
		MOD_MAC_TO_SAC				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC::Name() },  
		MOD_REMOVE_ARTISTALIAS		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTISTALIAS::Name() },  
		MOD_ADD_ARTISTALIAS		     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS::Name() },  
		MOD_ADD_RELEASE				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE::Name() },  
		MOD_ADD_ARTIST				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST::Name() },  
		MOD_ADD_TRACK_KV			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV::Name() },  
		MOD_REMOVE_ARTIST			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST::Name() },  
		MOD_REMOVE_DISCID			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID::Name() },  
		MOD_MOVE_DISCID			     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MOVE_DISCID::Name() },  
		MOD_MERGE_RELEASE			     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE::Name() },  
		MOD_REMOVE_RELEASES			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASES::Name() },  
		MOD_MERGE_RELEASE_MAC	    	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE_MAC::Name() },  
		MOD_EDIT_RELEASE_ATTRS	    	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_ATTRS::Name() },  
		MOD_EDIT_ARTISTALIAS		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS::Name() },  
		MOD_EDIT_RELEASE_EVENTS_OLD			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS_OLD::Name() },  
		MOD_ADD_ARTIST_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_ARTIST_ANNOTATION::Name() },  
		MOD_ADD_RELEASE_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_ANNOTATION::Name() },  
		MOD_ADD_TRACK_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_TRACK_ANNOTATION::Name() },  
		MOD_ADD_DISCID				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_DISCID::Name() },  
		MOD_ADD_LINK				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK::Name() },  
		MOD_EDIT_LINK				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK::Name() },  
		MOD_REMOVE_LINK			     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK::Name() },  
		MOD_ADD_LINK_TYPE			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_TYPE::Name() },  
		MOD_EDIT_LINK_TYPE			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE::Name() },  
		MOD_REMOVE_LINK_TYPE		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_TYPE::Name() },  
		MOD_EDIT_ARTIST			     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_ARTIST::Name() },  
		MOD_ADD_LINK_ATTR			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LINK_ATTR::Name() },  
		MOD_EDIT_LINK_ATTR			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LINK_ATTR::Name() },  
		MOD_REMOVE_LINK_ATTR		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LINK_ATTR::Name() },  
		MOD_EDIT_RELEASE_LANGUAGE	     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_LANGUAGE::Name() },  
		MOD_EDIT_TRACKTIME			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_TRACKTIME::Name() },  
		MOD_REMOVE_PUID			     ."" => { duration => 14, votes => 3, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_PUID::Name() },  
		MOD_ADD_PUIDS				 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_PUIDS::Name() },  
		MOD_CHANGE_WIKIDOC			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_CHANGE_WIKIDOC::Name() },  
		MOD_ADD_RELEASE_EVENTS		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_RELEASE_EVENTS::Name() },  
		MOD_EDIT_RELEASE_EVENTS		 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS::Name() },  
		MOD_REMOVE_RELEASE_EVENTS	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE_EVENTS::Name() },  
		MOD_SET_RELEASE_DURATIONS	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_SET_RELEASE_DURATIONS::Name() },  
		MOD_EDIT_URL				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_URL::Name() },  
		MOD_ADD_LABEL				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL::Name() },  
		MOD_ADD_LABEL_ANNOTATION	 ."" => { duration => 0, votes => 0, expireaction => EXPIRE_ACCEPT, autoedit => 1,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABEL_ANNOTATION::Name() },  
		MOD_ADD_LABELALIAS			 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_ADD_LABELALIAS::Name() },  
		MOD_REMOVE_LABEL        	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABEL::Name() },  
		MOD_REMOVE_LABELALIAS   	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_REMOVE_LABELALIAS::Name() },  
		MOD_EDIT_LABEL				 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABEL::Name() },  
		MOD_MERGE_LABEL         	 ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_MERGE_LABEL::Name() },  
		MOD_EDIT_LABELALIAS		     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_ACCEPT, autoedit => 0,  
		                                      name => &MusicBrainz::Server::Moderation::MOD_EDIT_LABELALIAS::Name() },  
	}
);

# The following two edit level definitions give the number of edit level details for moving the quality up or down.
my @QualityChangeDefs =
(
    # 0 == DOWN
	{ 
      duration => 14, 
      votes => 5, 
      expireaction => EXPIRE_REJECT, 
      autoedit => 0,  
      name => "Lower artist/release quality"
    },  
    # 1 == UP
	{ 
      duration => 3, 
      votes => 1, 
      expireaction => EXPIRE_ACCEPT, 
      autoedit => 0,  
      name => "Raise artist/release quality"
    }
);

# We'll store database handles that have open transactions in this hash for easy access.
local %Moderation::DBConnections = ();

sub GetQualityChangeDefs
{
    return $QualityChangeDefs[$_[0]];
}

sub GetEditTypes
{
    return keys %{$EditLevelDefs[QUALITY_NORMAL]};
}

sub GetEditLevelDefs
{
    my ($level, $type) = @_;

    # The line below is our OH-SHIT handle. If the new data quality system flies off the rails,
    # Uncomment the lines below to neuter it back to the OLD system.
    # my $defs = $EditLevelDefs[$level]->{QUALITY_NORMAL};
    # $defs->{duration} = 14;
    # $defs->{expireaction} = EXPIRE_KEEP_OPEN_IF_SUB;
    # $defs->{votes} = 3;
    # return $defs;

    # The level unknown is an internal state that will never be shown to the
    # the users. Users cannot set data quality back to unknown and yet
    # unknown behaves like a known level (determined by QUALITY_UNKNOWN_MAPPED)
    $level = QUALITY_UNKNOWN_MAPPED if $level == QUALITY_UNKNOWN;

    return $EditLevelDefs[$level]->{$type};
}

use constant SEARCHRESULT_SUCCESS => 1;
use constant SEARCHRESULT_NOQUERY => 2;
use constant SEARCHRESULT_TIMEOUT => 3;

use constant DEFAULT_SEARCH_TIMEOUT => 90;

my %ChangeNames = (
    &ModDefs::STATUS_OPEN			=> "Open",
    &ModDefs::STATUS_APPLIED		=> "Change applied",
    &ModDefs::STATUS_FAILEDVOTE		=> "Failed vote",
    &ModDefs::STATUS_FAILEDDEP		=> "Failed dependency",
    &ModDefs::STATUS_ERROR			=> "Internal error",
    &ModDefs::STATUS_FAILEDPREREQ	=> "Failed prerequisite",
    &ModDefs::STATUS_NOVOTES    	=> "No votes received",
    &ModDefs::STATUS_TOBEDELETED	=> "To be cancelled",
    &ModDefs::STATUS_DELETED		=> "Cancelled"
);

sub Refresh
{
	my $self = shift;
	my $newself = $self->CreateFromId($self->GetId);
	%$self = %$newself;
}

sub GetModerator
{
   return $_[0]->{moderator};
}

sub SetModerator
{
   $_[0]->{moderator} = $_[1];
}

sub GetExpired
{
   return $_[0]->{isexpired};
}

sub SetExpired
{
   $_[0]->{isexpired} = $_[1];
}

sub GetGracePeriodExpired
{
   return $_[0]->{isgraceexpired};
}

sub SetGracePeriodExpired
{
   $_[0]->{isgraceexpired} = $_[1];
}

sub GetOpenTime
{
   return $_[0]->{opentime};
}

sub SetOpenTime
{
   $_[0]->{opentime} = $_[1];
}

sub GetCloseTime
{
   return $_[0]->{closetime};
}

sub SetCloseTime
{
   $_[0]->{closetime} = $_[1];
}

sub GetExpireTime
{
   return $_[0]->{expiretime};
}

sub SetExpireTime
{
   $_[0]->{expiretime} = $_[1];
}

sub GetType
{
   return $_[0]->{type};
}

sub SetType
{
   $_[0]->{type} = $_[1];
}

sub GetStatus
{
   return $_[0]->{status};
}

sub SetStatus
{
   $_[0]->{status} = $_[1];
}

sub GetLanguageId
{
   return $_[0]->{language};
}

sub GetLanguage
{
	my $self = shift;
	my $id = $self->GetLanguageId or return undef;
	require MusicBrainz::Server::Language;
	return MusicBrainz::Server::Language->newFromId($self->{DBH}, $id);
}

sub SetLanguageId
{
   $_[0]->{language} = $_[1];
}

sub SetQuality
{
   $_[0]->{quality} = $_[1];
}

sub GetQuality
{
   # If the quality hasn't been set, call the moderation to figure it out
   $_[0]->{quality} = $_[0]->DetermineQuality()
       if (!exists $_[0]->{quality});
   return $_[0]->{quality};
}

sub IsOpen { $_[0]{status} == STATUS_OPEN or $_[0]{status} == STATUS_TOBEDELETED }

sub IsAutoEditType
{
   my ($this, $type) = @_;
   if ($this->GetType == MOD_CHANGE_RELEASE_QUALITY ||
       $this->GetType == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{automod};
   }
   my $level = GetEditLevelDefs($this->GetQuality, $type);
   return $level->{autoedit};
}

sub GetNumVotesNeeded
{
   my ($this) = @_;

   if ($this->GetType == MOD_CHANGE_RELEASE_QUALITY ||
       $this->GetType == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{votes};
   }
   my $level = GetEditLevelDefs($this->GetQuality, $this->GetType);
   return $level->{votes};
}

sub GetExpireAction
{
   my ($this) = @_;
   if ($this->GetType == MOD_CHANGE_RELEASE_QUALITY ||
       $this->GetType == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{expireaction};
   }
   my $level = GetEditLevelDefs($this->GetQuality, $this->GetType);
   return $level->{expireaction};
}

sub GetArtist
{
   return $_[0]->{artist};
}

sub SetArtist
{
   $_[0]->{artist} = $_[1];
}

sub GetYesVotes
{
   return $_[0]->{yesvotes};
}

sub SetYesVotes
{
   $_[0]->{yesvotes} = $_[1];
}

sub GetNoVotes
{
   return $_[0]->{novotes};
}

sub SetNoVotes
{
   $_[0]->{novotes} = $_[1];
}

sub GetTable
{
   return $_[0]->{table};
}

sub SetTable
{
   $_[0]->{table} = $_[1];
}

sub GetColumn
{
   return $_[0]->{column};
}

sub SetColumn
{
   $_[0]->{column} = $_[1];
}

sub GetRowId
{
   return $_[0]->{rowid};
}

sub SetRowId
{
   $_[0]->{rowid} = $_[1];
}

sub GetDepMod
{
   return $_[0]->{depmod};
}

sub SetDepMod
{
   $_[0]->{depmod} = $_[1];
}

sub GetPrev
{
   return $_[0]->{prev};
}

sub SetPrev
{
   $_[0]->{prev} = $_[1];
}

sub GetNew
{
   return $_[0]->{new};
}

sub SetNew
{
   $_[0]->{new} = $_[1];
}

sub GetVote
{
   return $_[0]->{vote};
}

sub SetVote
{
   $_[0]->{vote} = $_[1];
}

sub GetArtistName
{
   return $_[0]->{artistname};
}

sub SetArtistName
{
   $_[0]->{artistname} = $_[1];
}

sub GetArtistSortName
{
   return $_[0]->{artistsortname};
}

sub SetArtistSortName
{
   $_[0]->{artistsortname} = $_[1];
}

sub GetArtistResolution
{
   return $_[0]->{artistresolution};
}

sub SetArtistResolution
{
   $_[0]->{artistresolution} = $_[1];
}

sub GetModeratorName
{
   return $_[0]->{moderatorname};
}

sub SetModeratorName
{
   $_[0]->{moderatorname} = $_[1];
}

sub GetAutomod
{
   return $_[0]->{automod};
}

sub SetAutomod
{
   $_[0]->{automod} = $_[1];
}

sub GetError
{
   return $_[0]->{error};
}

sub SetError
{
   $_[0]->{error} = $_[1];
}

sub GetChangeName
{
   return $ChangeNames{$_[0]->{status}};
}

sub GetAutomoderatorList
{
   my ($this) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   require UserStuff;
   return $sql->SelectSingleColumnArray("select name from moderator where privs & " .
                                        &UserStuff::AUTOMOD_FLAG . " > 0 order by name");
}

# This function will load a change from the database and return
# a new ModerationXXXXXX object. Pass the rowid to load as the first arg
sub CreateFromId
{
   my ($this, $id) = @_;
   my ($edit, $query, $sql, @row);

   $query = qq/select m.id, tab, col, m.rowid, 
                      m.artist, m.type, prevvalue, newvalue, 
                      ExpireTime, Moderator.name, 
                      yesvotes, novotes, Artist.name, Artist.sortname, Artist.resolution, 
                      status, 0, depmod, Moderator.id, m.automod, m.language,
                      opentime, closetime,
                      ExpireTime < now(), ExpireTime + INTERVAL ? < now()
               from   moderation_all m, Moderator, Artist 
               where  Moderator.id = moderator and m.artist = 
                      Artist.id and m.id = ?/;

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query, &DBDefs::MOD_PERIOD_GRACE, $id))
   {
        @row = $sql->NextRow();
        $edit = $this->CreateModerationObject($row[5]);
        if (defined $edit)
        {
			$edit->SetId($row[0]);
			$edit->SetTable($row[1]);
			$edit->SetColumn($row[2]);
			$edit->SetRowId($row[3]);
			$edit->SetArtist($row[4]);
			$edit->SetType($row[5]);
			$edit->SetPrev($row[6]);
			$edit->SetNew($row[7]);
			$edit->SetExpireTime($row[8]);
			$edit->SetModeratorName($row[9]);
			$edit->SetYesVotes($row[10]);
			$edit->SetNoVotes($row[11]);
			$edit->SetArtistName($row[12]);
			$edit->SetArtistSortName($row[13]);
			$edit->SetArtistResolution($row[14]);
			$edit->SetStatus($row[15]);
			$edit->SetVote(&ModDefs::VOTE_UNKNOWN);
			$edit->SetDepMod($row[17]);
			$edit->SetModerator($row[18]);
			$edit->SetAutomod($row[19]);
			$edit->SetLanguageId($row[20]);
			$edit->SetOpenTime($row[21]);
			$edit->SetCloseTime($row[22]);
			$edit->SetExpired($row[23]);
			$edit->SetGracePeriodExpired($row[24]);
			$edit->PostLoad;
       }
   }

   $sql->Finish();
   return $edit;
}

sub iiMinMaxID
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my %opts = @_;

	my $open = $opts{"open"};

	require MusicBrainz::Server::Cache;
	my $key = "Moderation" . ($open ? "-open" : defined($open) ? "-closed" : "") . "-id-range";
	if (my $t = MusicBrainz::Server::Cache->get($key)) { return @$t }

	my $sql = Sql->new($self->{DBH});
	my ($min, $max) = $sql->GetColumnRange(
		($open ? "moderation_open"
		: defined($open) ? "moderation_closed"
		: [qw( moderation_open moderation_closed )])
	);

	$min ||= 0;
	$max ||= 0;

	my @range = ($min, $max);
	MusicBrainz::Server::Cache->set($key, \@range);
	return @range;
}

# Find the ID of the first message at or after $iTime
sub iFindByTime
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $sTime = shift;
	my %opts = @_;

	my $open = $opts{"open"};

	if ($sTime =~ /\A\d+\z/)
	{
		require POSIX;
		$sTime = POSIX::strftime("%Y-%m-%d %H:%M:%S", gmtime $sTime);
	}

	my ($iMin, $iMax) = $self->iiMinMaxID('open' => $opts{'open'});
	my $sql = Sql->new($self->{DBH});

	my $gettime = sub {
		$sql->SelectSingleValue(
			"SELECT opentime FROM moderation_all WHERE id = ?",
			0 + shift(),
		);
	};

	my $sMinTime = &$gettime($iMin);
	my $sMaxTime = &$gettime($iMax);
	return $iMin if $sTime le $sMinTime;
	return undef if $sTime gt $sMaxTime;

	while ($iMax-$iMin > 100)
	{
		#my $pct = ($iTime-$iMinTime) / ($iMaxTime-$iMinTime);
		my $pct = 0.5;
		my $iMid = int( $iMin + ($iMax-$iMin)*$pct );
		$iMid += 10 if $iMid == $iMin;
		$iMid -= 10 if $iMid == $iMax;
		my $oldmid = $iMid;
		my $sMidTime;

		for (;;)
		{
			$sMidTime = &$gettime($iMid)
				and last;
			++$iMid;
			die "No edits found between $oldmid and $iMax"
				if $iMid == $iMax;
		}

		if ($sMidTime lt $sTime)
		{
			$iMin = $iMid;
			$sMinTime = $sMidTime;
		} else {
			$iMax = $iMid;
			$sMaxTime = $sMidTime;
		}
	}

	$sql->SelectSingleValue(
		"SELECT MIN(id) FROM moderation_all
		WHERE id BETWEEN ? AND ?
		AND opentime >= ?",
		$iMin,
		$iMax,
		$sTime,
	);
}

# Use this function to create a new moderation object of the specified type
sub CreateModerationObject
{
	my ($this, $type) = @_;
	my $class = $this->ClassFromType($type)
		or die "Unknown moderation type $type";
	$class->new($this->{DBH});
}

# Insert a new moderation into the database.
sub InsertModeration
{
    my ($class, %opts) = @_;

	# If we're called as a nested insert, we provide the values for
	# these mandatory fields (so in this case, "type" is the only mandatory
	# field).
	if (ref $class)
	{
		$opts{DBH} = $class->{DBH};
		$opts{uid} = $class->GetModerator;
		$opts{privs} = $class->{_privs_};
	}

    # in some cases there are nested transaction (e.g. some album merges) where
    # we specfically do not want to start a new transaction
    my $notrans = exists $opts{notrans};

	# Process the required %opts keys - DBH, type, uid, privs.
	my $privs;
	my $this = do {
		my $t = $opts{'type'}
			or die "No type passed to Moderation->InsertModeration";
		my $editclass = $class->ClassFromType($t)
			or die "No such moderation type #$t";

		my $this = $editclass->new($opts{'DBH'} || die "No DBH passed");
		$this->SetType($this->Type);

		$this->SetModerator($opts{'uid'} or die "No uid passed");
		defined($privs = $opts{'privs'}) or die;

		delete @opts{qw( type DBH uid privs )};

		$this;
	};

	# Save $privs in $self so that if a nested ->InsertModeration is called,
	# we know what privs to use (see above).
	$this->{_privs_} = $privs;

	# The list of moderations inserted by this call.
	my @inserted_moderations;
	$this->{inserted_moderations} = \@inserted_moderations;

	my ($sql, $vertsql);
    if ($notrans)
	{
        $sql = $Moderation::DBConnections{READWRITE};
        $vertsql = $Moderation::DBConnections{RAWDATA};
	}
	else
    {
		$sql = Sql->new($this->{DBH});
		my $vertmb = new MusicBrainz;
		$vertmb->Login(db => 'RAWDATA');
		$vertsql = Sql->new($vertmb->{DBH});

        $sql->Begin;
        $vertsql->Begin;

        $Moderation::DBConnections{READWRITE} = $sql;
        $Moderation::DBConnections{RAWDATA} = $vertsql;
    }

	eval
	{

		# The PreInsert method must perform any work it needs to - e.g. inserting
		# records which maybe ->DeniedAction will delete later - and then override
		# these default column values as appropriate:
		$this->SetArtist(&ModDefs::VARTIST_ID);
		$this->SetTable("");
		$this->SetColumn("");
		$this->SetRowId(0);
		$this->SetDepMod(0);
		$this->SetPrev("");
		$this->SetNew("");
		$this->PreInsert(%opts);

		goto SUPPRESS_INSERT if $this->{suppress_insert};
		$this->PostLoad;

		my $level;
		if ($this->GetType == &Moderation::MOD_CHANGE_RELEASE_QUALITY ||
		    $this->GetType == &Moderation::MOD_CHANGE_ARTIST_QUALITY)
		{
			$level = Moderation::GetQualityChangeDefs($this->GetQualityChangeDirection);
		}
		else
		{
			$level = Moderation::GetEditLevelDefs($this->GetQuality, $this->GetType);
		}

		# Now go on to insert the moderation record itself, and to
		# deal with autoeditss and modpending flags.

		use DebugLog;
		if (my $d = DebugLog->open)
		{
			$d->stamp;
			$d->dumper([$this], ['this']);
			$d->dumpstring($this->{prev}, "this-prev");
			$d->dumpstring($this->{new}, "this-new");
			$d->close;
		}

		$sql->Do(
            "INSERT INTO moderation_open (
                tab, col, rowid,
                prevvalue, newvalue,
                moderator, artist, type,
                depmod,
                status, expiretime, yesvotes, novotes, automod, language
            ) VALUES (
                ?, ?, ?,
                ?, ?,
                ?, ?, ?,
                ?,
                ?, NOW() + INTERVAL ?, 0, 0, 0, ?
            )",
            $this->GetTable, $this->GetColumn, $this->GetRowId,
            $this->GetPrev, $this->GetNew,
            $this->GetModerator, $this->GetArtist, $this->GetType,
            $this->GetDepMod,
            &ModDefs::STATUS_OPEN, sprintf("%d days", $level->{duration}),
            $this->GetLanguageId
		);

		my $insertid = $sql->GetLastInsertId("moderation_open");
		MusicBrainz::Server::Cache->delete("Moderation-id-range");
		MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
		#print STDERR "Inserted as moderation #$insertid\n";
		$this->SetId($insertid);

		# Check to see if this moderation should be approved immediately 
		require UserStuff;
		my $ui = UserStuff->new($this->{DBH});
		my $isautoeditor = $ui->IsAutoEditor($privs);

		my $autoedit = 0;

		# If the edit allows an autoedit and the current level allows autoedits, then make it an autoedit
		$autoedit = 1 if (not $autoedit
		                  and $this->IsAutoEdit($isautoeditor) 
		                  and $level->{autoedit});

		# If the edit type is an autoedit and the editor is an autoedit, then make it an autoedit
		$autoedit = 1 if (not $autoedit
		                  and $isautoeditor
		                  and $level->{autoedit});

		# If the editor is untrusted, undo the auto edit
		$autoedit = 0 if ($ui->IsUntrusted($privs) and $this->GetType != &ModDefs::MOD_ADD_PUIDS);

		# If it is autoedit, then approve the edit and credit the editor
		if ($autoedit)
		{
			my $edit = $this->CreateFromId($insertid);
			my $status = $edit->ApprovedAction;

			$sql->Do("UPDATE moderation_open SET status = ?, automod = 1 WHERE id = ?",
				$status,
				$insertid,
			);

			require UserStuff;
			my $user = UserStuff->new($this->{DBH});
			$user->CreditModerator($this->{moderator}, $status, $autoedit);

			MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
			MusicBrainz::Server::Cache->delete("Moderation-closed-id-range");
		}
		else
		{
			$this->AdjustModPending(+1);
		}

		push @inserted_moderations, $this;

SUPPRESS_INSERT:

		# XXX: This won't work, because we are already in a DB
		#      transaction. Do we need this at all? This was broken
		#      for a long time because we had the transaction outside
		#      of this method, and there is no call to PushModeration
		#      in the source code, as far as I can see.
		# Deal with any calls to ->PushModeration
		for my $opts (@{ $this->{pushed_moderations} })
		{
			# Note that we don't have to do anything with the returned
			# moderations because of the next block, about four lines down.
			$this->InsertModeration(%$opts);
		}

		# Ensure our inserted moderations get passed up to our parent,
		# if this is a nested call to ->InsertModeration.
		push @{ $class->{inserted_moderations} }, @inserted_moderations
			if ref $class;

		# Save problems with self-referencing and garbage collection
		delete $this->{inserted_moderations};

        if (!$notrans)
        {
            delete $Moderation::DBConnections{READWRITE};
            delete $Moderation::DBConnections{RAWDATA};

            $vertsql->Commit;
            $sql->Commit;
        }
	};

	if ($@)
	{
		my $err = $@;
        if (!$notrans)
        {
            delete $Moderation::DBConnections{READWRITE};
            delete $Moderation::DBConnections{RAWDATA};
            $vertsql->Rollback;
            $sql->Rollback;
        }
		croak $err;
	};

	wantarray ? @inserted_moderations : pop @inserted_moderations;
}

sub GetMaxModID
{
	my $self = shift;
	($self->iiMinMaxID(@_))[1];
}

sub OpenModsByType_as_hashref
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfLists(
		"SELECT type, COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." GROUP BY type",
	);

	+{
		map { $_->[0] => $_->[1] } @$rows
	};
}

sub OpenModCountByModerator
{
	my $self = shift;
	my $editor = shift;
	my $sql = Sql->new($self->{DBH});

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." and moderator = ?",
        $editor
	);
}

# This function returns the list of moderations to
# be shown on one moderation page.  It returns an array
# of references to Moderation objects.

sub GetModerationList
{
	my ($this, $query, $voter, $index, $num) = @_;
	$query or return SEARCHRESULT_NOQUERY;

	my $sql = Sql->new($this->{DBH});

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = " . int(DEFAULT_SEARCH_TIMEOUT*1000));

	my $ok = eval {
		local $sql->{Quiet} = 1;
		$query .= " OFFSET " . ($index||0);
		$sql->Select($query);
		1;
	};
	my $err = $@;

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = DEFAULT");

	if (not $ok)
	{
		if ($sql->is_timeout($err))
		{
			warn "Moderation search timed out.  The query was: $query\n";
			return SEARCHRESULT_TIMEOUT;
		}

		die $err;
	}

	my @edits;

	while (@edits < $num)
	{
		my $r = $sql->NextRowHashRef
			or last;
		my $edit = $this->CreateModerationObject($r->{type});

		unless ($edit)
		{
			print STDERR "Could not create moderation object for type=$r->{type}\n";
			next;
		}

		$edit->SetId($r->{id});
		$edit->SetArtist($r->{artist});
		$edit->SetModerator($r->{moderator});
		$edit->SetTable($r->{tab});
		$edit->SetColumn($r->{col});
		$edit->SetType($r->{type});
		$edit->SetStatus($r->{status});
		$edit->SetRowId($r->{rowid});
		$edit->SetPrev($r->{prevvalue});
		$edit->SetNew($r->{newvalue});
		$edit->SetYesVotes($r->{yesvotes});
		$edit->SetNoVotes($r->{novotes});
		$edit->SetDepMod($r->{depmod});
		$edit->SetAutomod($r->{automod});
		$edit->SetOpenTime($r->{opentime});
		$edit->SetCloseTime($r->{closetime});
		$edit->SetExpireTime($r->{expiretime});
		$edit->SetLanguageId($r->{language});

		$edit->SetExpired($r->{expired});
		$edit->SetVote($r->{vote});

		push @edits, $edit;
	}

	my $total_rows = $sql->Rows;

	$sql->Finish;

	# Fetch artists, and cache by artistid.
	require MusicBrainz::Server::Artist;
	my %artist_cache;
	
	# Cache editors by name
	require UserStuff;
	my $user = UserStuff->new($this->{DBH});
	my %editor_cache;
		
	require MusicBrainz::Server::Vote;
	my $vote = MusicBrainz::Server::Vote->new($this->{DBH});

	for my $edit (@edits)
	{
		# Fetch editor into cache if not loaded before.
		my $uid = $edit->GetModerator;
		$editor_cache{$uid} = do {
			my $u = $user->newFromId($uid);
			$u ? $u->GetName : "?";
		} unless defined $editor_cache{$uid};
		$edit->SetModeratorName($editor_cache{$uid});

		# Fetch artist into cache if not loaded before.
		my $artistid = $edit->GetArtist;
		if (not defined $artist_cache{$artistid})
		{
			my $artist = MusicBrainz::Server::Artist->new($this->{DBH});
			$artist->SetId($artistid);
			if ($artist->LoadFromId())
			{
				$artist_cache{$artistid} = $artist;
			} 
		}
		
		my $artist = $artist_cache{$artistid};
		$edit->SetArtistName($artist ? $artist->GetName : "?");
		$edit->SetArtistSortName($artist ? $artist->GetSortName : "?");
		$edit->SetArtistResolution($artist ? $artist->GetResolution : "?");

		# Find vote
		if ($edit->GetVote == VOTE_UNKNOWN and $voter)
		{
			my $thevote = $vote->GetLatestVoteFromUser($edit->GetId, $voter);
			$edit->SetVote($thevote);
		}
	}

	for (@edits) {
		$_->PostLoad;
		$_->PreDisplay;
	}

	return (SEARCHRESULT_SUCCESS, \@edits, $index+$total_rows);
}

################################################################################

sub CloseModeration
{
	my ($this, $status) = @_;
	use Carp qw( confess );
	confess "CloseModeration called where status is false"
		if not $status;
	confess "CloseModeration called where status is STATUS_OPEN"
		if $status == STATUS_OPEN;
	confess "CloseModeration called where status is STATUS_TOBEDELETED"
		if $status == STATUS_TOBEDELETED;

	# Decrement the mod count in the data row
	$this->AdjustModPending(-1);

 	# Set the status in the Moderation row
  	my $sql = Sql->new($this->{DBH});
   	$sql->Do(
		"UPDATE moderation_open SET status = ? WHERE id = ?",
		$status,
		$this->GetId,
	);

	MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
	MusicBrainz::Server::Cache->delete("Moderation-closed-id-range");
}

sub RemoveModeration
{
   my ($this, $uid) = @_;
  
   if ($this->GetStatus() == &ModDefs::STATUS_OPEN)
   {
		# Set the status to be deleted.  The ModBot will clean it up
		# on its next pass.
		my $sql = Sql->new($this->{DBH});
		$sql->Do(
			"UPDATE moderation_open SET status = ?
			WHERE id = ? AND moderator = ? AND status = ?",
	   		&ModDefs::STATUS_TOBEDELETED,
			$this->GetId,
			$uid,
	   		&ModDefs::STATUS_OPEN,
		);
   }
}

# Links to the ModerationNote class

sub Notes
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->newFromModerationId($self->GetId);
}

sub InsertNote
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->Insert($self->GetId, @_);
}

# Links to the Vote class

sub Votes
{
	my $self = shift;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	$votes->newFromModerationId($self->GetId);
}

sub VoteFromUser
{
	my ($self, $uid) = @_;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	# The number of votes per mod is small, so we may as well just retrieve
	# all votes for the mod, then find the one we want.
	my @votes = $votes->newFromModerationId($self->GetId);
	# Pick the most recent vote from this user
	(my $thevote) = reverse grep { $_->GetUserId == $uid } @votes;
	$thevote;
}

sub FirstNoVote
{
	my ($self, $voter_uid) = @_;

	require UserStuff;
	my $editor = UserStuff->newFromId($self->{DBH}, $self->GetModerator);
	my $voter = UserStuff->newFromId($self->{DBH}, $voter_uid);

	require UserPreference;
	my $send_mail = UserPreference::get_for_user('mail_on_first_no_vote', $editor);
	$send_mail or return;

	my $url = "http://" . &DBDefs::WEB_SERVER . "/show/edit/?editid=" . $self->GetId;

	my $body = <<EOF;
Editor '${\ $voter->GetName }' has voted against your edit #${\ $self->GetId }.
------------------------------------------------------------------------
If you would like to respond to this vote, please add your note at:
$url
Please do not respond to this e-mail.

This e-mail is only sent for the first vote against your edit, not for each
one. If you would prefer not to receive these e-mails, please adjust your
preferences accordingly at http://${\ DBDefs::WEB_SERVER() }/user/preferences.html
EOF

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		# Sender: not required
		From		=> 'MusicBrainz <webserver@musicbrainz.org>',
		# To: $self (automatic)
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Someone has voted against your edit",
		References	=> '<edit-'.$self->GetId.'@'.&DBDefs::WEB_SERVER.'>',
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	$editor->SendFormattedEmail(entity => $mail);
}

################################################################################

sub TopModerators
{
	my ($self, %opts) = @_;

	my $nl = $opts{namelimit} || 11;
	$nl = 6 if $nl < 6;
	my $nl2 = $nl-3;

	$opts{rowlimit} ||= 5;
	$opts{interval} ||= "1 week";

	my $sql = Sql->new($self->{DBH});

	$sql->SelectListOfHashes(
		"SELECT	u.id, u.name,
				CASE WHEN LENGTH(name)<=$nl THEN name ELSE SUBSTR(name, 1, $nl2) || '...' END
				AS nametrunc,
				COUNT(*) AS num
		FROM	moderation_all m, moderator u
		WHERE	m.moderator = u.id
		AND		u.id != " . FREEDB_MODERATOR ."
		AND		u.id != " . MODBOT_MODERATOR ."
		AND		m.opentime > NOW() - INTERVAL ?
		GROUP BY u.id, u.name
		ORDER BY num DESC
		LIMIT ?",
		$opts{interval},
		$opts{rowlimit},
	);
}

sub TopAcceptedModeratorsAllTime
{
	my ($self, %opts) = @_;

	my $nl = $opts{namelimit} || 11;
	$nl = 6 if $nl < 6;
	my $nl2 = $nl-3;

	$opts{rowlimit} ||= 5;

	my $sql = Sql->new($self->{DBH});

	$sql->SelectListOfHashes(
		"SELECT	id, name,
				CASE WHEN LENGTH(name)<=$nl THEN name ELSE SUBSTR(name, 1, $nl2) || '...' END
				AS nametrunc,
				modsaccepted + automodsaccepted AS num
		FROM	moderator
		WHERE	id != " . FREEDB_MODERATOR ."
		AND		id != " . MODBOT_MODERATOR ."
		ORDER BY num DESC
		LIMIT ?",
		$opts{rowlimit},
	);
}

################################################################################
# Sub-class registration
################################################################################

{
	our %subs;

	sub RegisterHandler
	{
		my $subclass = shift;
		my $type = $subclass->Type;
		
		if (my $existing = $subs{$type})
		{
			$existing eq $subclass
				or die "$subclass and $existing both claim moderation type $type";
		}

		$subs{$type} = $subclass;
	}

	sub ClassFromType
	{
		my ($class, $type) = @_;
		$subs{$type};
	}

	sub RegisteredMods { \%subs }
}

################################################################################
# Methods which sub-classes should probably not override
################################################################################

sub Token
{
	my $self = shift;
	my $classname = ref($self) || $self;

	(my $token) = (reverse $classname) =~ /^(\w+)/;
	$token = reverse $token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Token => '$token'";
	eval "sub ${classname}::Token() { '$token' }";
	die $@ if $@;

	$token;
}

sub Type
{
	my $self = shift;
	my $classname = ref($self) || $self;

	require ModDefs;
	my $token = $self->Token;
	my $type = ModDefs->$token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Type => $type";
	eval "sub ${classname}::Type() { $type }";
	die $@ if $@;

	$type;
}

sub GetComponent
{
	my ($self, $mason) = @_;
	my $token = $self->Token;
	$mason->fetch_comp("/comp/moderation/$token")
		or die "Failed to find Mason component for $token";
}

# This function will get called from the html pages to output the
# contents of the moderation type field.
sub ShowModType
{
	my ($this, $mason, $showeditlinks) = splice(@_, 0, 3);
	
	use MusicBrainz qw( encode_entities );
	
	# default exists is to check if the given name is set
	# in the values hash.
	($this->{"exists-album"}, $this->{"exists-track"}) =  ($this->{"albumname"}, $this->{"trackname"});

	# attempt to load track entity, and see if it still exists.
	# --- this flag was set in the individual PostLoad
	#     implementations of the edit types
	if ($this->{"checkexists-track"} && defined $this->{"trackid"})
	{
		require MusicBrainz::Server::Track;
		my $track = MusicBrainz::Server::Track->new($this->{DBH});
		$track->SetId($this->{"trackid"});
		if ($this->{"exists-track"} = $track->LoadFromId)
		{
			$this->{"trackid"} = $track->GetId;
			$this->{"trackname"} = $track->GetName;
			$this->{"trackseq"} = $track->GetSequence;
			
			# assume that the release needs to be loaded from
			# the album-track core relationship, if it not
			# has been set explicitly.
			$this->{"albumid"} = $track->GetRelease if ($this->{"checkexists-album"} && not defined $this->{"albumid"});
		}
	}
	
	# attempt to load release entity, and see if it still exists
	# --- this flag was set in the individual PostLoad
	#     implementations of the edit types	
	if ($this->{"checkexists-album"} && defined $this->{"albumid"})
	{
		require MusicBrainz::Server::Release;
		my $release = MusicBrainz::Server::Release->new($this->{DBH});
		$release->SetId($this->{"albumid"});
		if ($this->{"exists-album"} = $release->LoadFromId)
		{
			$this->{"albumid"} = $release->GetId;
			$this->{"albumname"} = $release->GetName;
			$this->{"trackcount"} = $release->GetTrackCount;
			$this->{"isnonalbum"} = $release->IsNonAlbumTracks;
		}	
	}
	
	# do not display release if we have a batch edit type
	$this->{"albumid"} = undef 
		if ($this->GetType == &ModDefs::MOD_REMOVE_RELEASES or
			$this->GetType == &ModDefs::MOD_MERGE_RELEASE or
			$this->GetType == &ModDefs::MOD_MERGE_RELEASE_MAC or
			$this->GetType == &ModDefs::MOD_EDIT_RELEASE_LANGUAGE or
			$this->GetType == &ModDefs::MOD_EDIT_RELEASE_ATTRS);
	
	$mason->out(qq!<table class="edittype">!);

	# output edittype as wikidoc link
	$mason->out(qq!<tr class="entity"><td class="lbl">Type:</td><td>!);
	my $docname = $this->Name."Edit";
	$docname =~ s/\s//g;
	$mason->comp("/comp/linkdoc", $docname, $this->Name);
	if ($this->GetAutomod)
	{
		$mason->out(qq! &nbsp; <small>(<a href="/doc/AutoEdit">Autoedit</a>)</small>!);
 	}
 	
	# if current/total number of tracks is available, show the info...
	# ...but do not show sequence number for non-album tracks
	my $seq = "";
	if (!$this->{"isnonalbum"})
	{
		$seq = ($this->{"trackseq"} 
			? " &nbsp; <small>(Track: " . $this->{"trackseq"} 
				  . ($this->{"trackcount"} 
					? "/".$this->{"trackcount"}
					: "")
				  . ")</small>"
			: "");	
	}
	$mason->out(qq!$seq</td></tr>!);
	

	# output the artist this edit is listed under.
	if (!$this->{'dont-display-artist'})
	{
		$mason->out(qq!<tr class="entity"><td class="lbl">Artist:</td>!);
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linkartist", 
			id => $this->GetArtist, 
			name => $this->GetArtistName, 
			sortname => $this->GetArtistSortName, 
			resolution => $this->GetArtistResolution,
			strong => 0
		);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "artist", id => $this->GetArtist, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);	
	}
	
	
	# output the release this edit is listed under.
	if (defined $this->{"albumid"})
	{
		my ($id, $name, $title) = ($this->{"albumid"}, $this->{"albumname"}, undef);
		if (not $this->{"exists-album"})
		{
			$name = "This release has been removed" if (not defined $name);
			$title = "This release has been removed, Id: $id";
			$id = -1;	
		}
		
		$mason->out(qq!<tr class="entity"><td class="lbl">Release:</td>!);	
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linkrelease", id => $id, name => $name, title => $title, strong => 0);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "release", id => $id, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);	
	}

	# output the track this edit is listed under.
	if (defined $this->{"trackid"})
	{
		my ($id, $name, $title) = ($this->{"trackid"}, $this->{"trackname"}, undef);
		if (not $this->{"exists-track"})
		{
			$name = "This track has been removed" if (not defined $name);
			$title = "This track has been removed, Id: $id";
			$id = -1;
		}
		$mason->out(qq!<tr class="entity"><td class="lbl">Track:</td>!);	
		$mason->out(qq!<td>!);
		$mason->comp("/comp/linktrack", id => $id, name => $name, title => $title, strong => 0);
		$mason->out(qq!</td>!);
		if ($showeditlinks)
		{
			$mason->out(qq!<td class="editlinks">!);
			$mason->comp("/comp/linkedits", type => "track", id => $id, explain => 1);
			$mason->out(qq!</td>!);
		}
		$mason->out(qq!</tr>!);		
	}	
	
	# call delegate method that can be overriden by the edit types
	# to provide additional links to entities.
	$this->ShowModTypeDelegate($mason);
	
	# close the table.
	$mason->out(qq!</table>!);
}

# This method can be overridden by subclasses to display additional rows
# in the table rendered by ShowModType.
sub ShowModTypeDelegate
{
	my ($this, $mason) = (shift, shift);
	
	# do something, or not.
}

sub ShowPreviousValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowPreviousValue", $this, @_);
}

sub ShowNewValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowNewValue", $this, @_);
}

################################################################################
# Methods which must be implemented by sub-classes
################################################################################

# (class)
# sub Name { "Remove Disc ID" }

# (instance)
# A moderation is being inserted - perform additional actions here, such as
# actually inserting.  Throw an exception if the arguments are invalid.
# Arguments: %opts, (almost) as passed to Moderation->InsertModeration
# Called in void context
# sub PreInsert;

################################################################################
# Methods intended to be overridden by moderation sub-classes
################################################################################

# PostLoad is called after an object of this class has been instantiated
# and its fields have been set via ->SetPrev, ->SetNew etc.  The class should
# then prepare any internal fields it requires, e.g. parse 'prev' and 'new'
# into various internal fields.  An exception should be thrown if appropriate,
# e.g. if 'prev' or 'new' don't parse as required.  The return value is
# ignored (this method will usually be called in void context).  The default
# action is to do nothing.
# Arguments: none
# Called in void context
sub PostLoad { }

# PreDisplay should be implemented to load additional data that is necessary for
# displaying the moderation in the web interface, so mason scripts can be kept
# clean from data gathering statements.
# It could be used to load the track name that is not stored in moderation tables
# for moderations modifying the track table, for example.
# Arguments: none
# Called in void context
sub PreDisplay { }

# Can this moderation be automatically applied?  (Based on moderation type
# and data, not the moderator). There merely states if the edit can be
# automatically applied -- wether it will or will not be, depends on the data
# quality setting for the artist/release in question.
# Arguments: $isautoeditor (boolean)
# Called in boolean context; return true to automod this moderation
sub IsAutoEdit { 0 }

# Adjust the appropriate "modpending" flags.  $adjust is guaranteed to be
# either +1 (add one pending mod) or -1 (subtract one).
# Arguments: $adjust (guaranteed to be either +1 or -1)
# Called in void context
# TODO remove this implementation; leave each handler to implement it
# themselves.
sub AdjustModPending
{
	my ($this, $adjust) = @_;
	my $table = lc $this->GetTable;

	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE $table SET modpending = modpending + ? WHERE id = ?",
		$adjust,
		$this->GetRowId,
	);
}

# Determine the current quality level that should be applied to this edit.
# The subclasses will need to determine if an edit is an artist edit or
# a release edit and then look up the quality for that entity and
# return it from this function. This causes the quality for an edit
# to be considered every time the ModBot examines it.
sub DetermineQuality { QUALITY_NORMAL };

# Determine if a change quality edit is going up (1) or down (0)
sub GetQualityChangeDirection { 1 }; # default to up, which is more strict

# Check the moderation to see if it can still be applied, e.g. that all the
# prerequisites and other dependencies are still OK.  If all is well, return
# "undef".  Otherwise, return one of the "bad" STATUS_* codes (e.g.
# STATUS_FAILEDPREREQ).  You might want to add a note using
# $self->InsertNote(MODBOT_MODERATOR, $message) too.  Either way the
# transaction will be committed if possible.
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_* or undef.
sub CheckPrerequisites { undef }

# The moderation has been approved - either immediately (automod), or voted
# in.  Either throw an exception (in which case the transaction will be rolled
# back), or do whatever work is necessary and return &ModDefs::STATUS_* (in
# which case the transaction will probably be committed).
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_*
sub ApprovedAction { &ModDefs::STATUS_APPLIED }

# The moderation is to be undone (voted down, failed a test, or was deleted)
# Arguments: none
# Called in void context
sub DeniedAction { () }

################################################################################
# Utility methods for moderation handlers
################################################################################

# If a mod handler wants to insert another moderation before itself, it just
# calls ->InsertModeration as an instance method, passing %opts as normal.  It
# doesn't need to specify the DBH, uid or privs options though.  The return
# value of ->InsertModeration can be ignored too, if you like.

# If a mod handler wants another moderation to be inserted after itself, it
# calls ->PushModeration, with the same arguments as for a nested call to
# ->InsertModeration (see above).  Nothing special is returned.
sub PushModeration
{
	my ($self, %opts) = @_;
	push @{ $self->{pushed_moderations} }, \%opts;
}

# If a mod handler wants to suppress insertion of itself (for example, maybe
# because it called ->InsertModeration or ->PushModeration to generate a
# replacement moderation), it calls ->SuppressInsert (no arguments, and no
# special return value).
sub SuppressInsert
{
	my $self = shift;
	$self->{suppress_insert} = 1;
}

sub ConvertNewToHash
{
	my ($this, $nw) = @_;
	my %kv;

	for (split /\n/, $nw)
	{
	   	my ($k, $v) = split /=/, $_, 2;
		return undef unless defined $v;
		$kv{$k} = $this->_decode_value($v);
	}

	\%kv;
}

sub ConvertHashToNew
{
	my ($this, $kv) = @_;

	my @undef_keys = grep { not defined $kv->{$_} } keys %$kv;
	carp "Uninitialized value(s) @undef_keys passed to ConvertHashToNew"
		if @undef_keys;

	join "\n", map {
		my $k = $_;
		$k . '=' . $this->_encode_value($kv->{$k});
	} sort keys %$kv;
}

use URI::Escape qw( uri_escape uri_unescape );

sub _encode_value
{
	return $_[1] unless $_[1] =~ /[\x00-\x1F\x7F]/;
	"\x1BURI;" . uri_escape($_[1], '\x00-\x1F\x7F%');
}

sub _decode_value
{
	my ($scheme, $data) = $_[1] =~ /\A\x1B(\w+);(.*)\z/s
		or return $_[1];
	return uri_unescape($data) if $scheme eq "URI";
	die "Unknown encoding scheme '$scheme'";
}

sub _normalise_strings
{
	my $this = shift;

	my @r = map {
		# Normalise to lower case
		my $t = lc decode("utf-8", $_);

		# Remove leading and trailing space
		$t =~ s/\A\s+//;
		$t =~ s/\s+\z//;

		# Compress whitespace
		$t =~ s/\s+/ /g;

		# So-called smart quotes; in reality, a backtick and an acute accent.
		# Also double-quotes and angled double quotes.
		$t =~ tr/\x{0060}\x{00B4}"\x{00AB}\x{00BB}/'/;

		# Unaccent what's left
		$t = decode("utf-8", unaccent(encode("utf-8", $t)));

		$t;
	} @_;

	wantarray ? @r : $r[-1];
}

1;
# vi: set ts=4 sw=4 :
