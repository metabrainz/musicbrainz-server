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
use ModDefs ':DEFAULT';
use MusicBrainz::Server::Language;
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
		MOD_REMOVE_PUID			     ."" => { duration => 14, votes => 4, expireaction => EXPIRE_REJECT, autoedit => 0,  
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

sub entity_type { 'moderation' }

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
	my $newself = $self->CreateFromId($self->id);
	%$self = %$newself;
}

sub moderator
{
    my ($self, $new_moderator) = @_;

    if (defined $new_moderator) { $self->{moderator} = $new_moderator; }
    return $self->{moderator};
}

sub expired
{
    my ($self, $new_expired) = @_;

    if (defined $new_expired) { $self->{isexpired} = $new_expired; }
    return $self->{isexpired};
}

sub show_artist
{
    my ($self, $new_show_artist) = @_;

    if (defined $new_show_artist) { $self->{'dont-display-artist'} = !$new_show_artist; }
    return !$self->{'dont-display-artist'};
}

sub grace_period_expired
{
    my ($self, $new_expired) = @_;

    if (defined $new_expired) { $self->{isgraceexpired} = $new_expired; }
    return $self->{isgraceexpired};
}

sub open_time
{
    my ($self, $new_time) = @_;

    if (defined $new_time) { $self->{opentime} = $new_time; }
    return $self->{opentime};
}

sub close_time
{
    my ($self, $new_time) = @_;

    if (defined $new_time) { $self->{closetime} = $new_time; }
    return $self->{closetime};
}

sub expire_time
{
    my ($self, $new_time) = @_;

    if (defined $new_time) { $self->{expiretime} = $new_time; }
    return $self->{expiretime};
}

sub type
{
    my ($self, $new_type) = @_;

    if (defined $new_type) { $self->{type} = $new_type; }
    return $self->{type};
}

sub status
{
    my ($self, $new_status) = @_;

    if (defined $new_status) { $self->{status} = $new_status; }
    return $self->{status};
}

sub language
{
    my ($self, $new_language) = @_;

    if (defined $new_language) { $self->{language} = $new_language; }
    return $self->{language};
}

sub quality
{
    my ($self, $new_quality) = @_;

    if (defined $new_quality) { $self->{quality} = $new_quality; }

    # If the quality hasn't been set, call the moderation to figure it out
    if (!exists $self->{quality}) { $self->{quality} = $self->DetermineQuality(); }

    return $self->{quality};
}

sub is_open { $_[0]{status} == STATUS_OPEN or $_[0]{status} == STATUS_TOBEDELETED }

sub is_auto_edit_type
{
   my ($this, $type) = @_;
   if ($this->type == MOD_CHANGE_RELEASE_QUALITY ||
       $this->type == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{automod};
   }
   my $level = GetEditLevelDefs($this->quality, $type);
   return $level->{autoedit};
}

sub num_votes_needed
{
   my ($this) = @_;

   if ($this->type == MOD_CHANGE_RELEASE_QUALITY ||
       $this->type == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{votes};
   }
   my $level = GetEditLevelDefs($this->quality, $this->type);
   return $level->{votes};
}

sub expire_action
{
   my ($this) = @_;
   if ($this->type == MOD_CHANGE_RELEASE_QUALITY ||
       $this->type == MOD_CHANGE_ARTIST_QUALITY)
   {
        return $QualityChangeDefs[$this->GetQualityChangeDirection]->{expireaction};
   }
   my $level = GetEditLevelDefs($this->quality, $this->type);
   return $level->{expireaction};
}

sub artist
{
    my ($self, $new_artist) = @_;

    if (defined $new_artist)
    {
        if (ref $new_artist)
        {
            $self->{artist} = $new_artist;
        }
        else
        {
            $self->{artist} = new MusicBrainz::Server::Artist($self->{dbh});
            $self->{artist}->id($new_artist);
        }
    }

    return $self->{artist};
}

sub track
{
    my ($self, $new_track) = @_;

    if (defined $new_track) { $self->{trackid} = $new_track; }

    # This wouldn't need to be so funky if we actually used accessors...
    if (defined $new_track ||
        (!defined $self->{track} && defined $self->{trackid}))
    {
        # TODO track should get and set Track objects, not ids!
        $self->{track} = MusicBrainz::Server::Track->new($self->dbh);
        $self->{track}->id($self->{trackid});
        $self->{track}->LoadFromId;
    }

    return $self->{track};
}

sub release
{
    my ($self, $new_release) = @_;

    if (defined $new_release) { $self->{albumid} = $new_release; }

    if (defined $new_release || (!defined $self->{release} && defined $self->{albumid}))
    {
        # TODO release should get and set Release objects, not ids!
        $self->{release} = MusicBrainz::Server::Release->new($self->dbh);
        $self->{release}->id($self->{albumid});
        $self->{release}->LoadFromId;
    }

    return $self->{release};
}

sub label
{
    my ($self, $new_label) = @_;

    if (defined $new_label) { $self->{labelid} = $new_label; }

    if (defined $new_label || (!defined $self->{label} && defined $self->{labelid}))
    {
        # TODO release should get and set Release objects, not ids!
        $self->{label} = MusicBrainz::Server::Label->new($self->dbh);
        $self->{label}->id($self->{labelid});
        $self->{label}->LoadFromId;
    }

    return $self->{label};
}

sub yes_votes
{
    my ($self, $new_votes) = @_;

    if (defined $new_votes) { $self->{yesvotes} = $new_votes; }
    return $self->{yesvotes};
}

sub no_votes
{
    my ($self, $new_votes) = @_;

    if (defined $new_votes) { $self->{novotes} = $new_votes; }
    return $self->{novotes};
}

sub table
{
    my ($self, $new_table) = @_;

    if (defined $new_table) { $self->{table} = $new_table; }
    return $self->{table};
}

sub column
{
    my ($self, $new_column) = @_;

    if (defined $new_column) { $self->{column} = $new_column; }
    return $self->{column};
}

sub row_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{rowid} = $new_id; }
    return $self->{rowid};
}

sub dep_mod
{
    my ($self, $new_mod) = @_;

    if (defined $new_mod) { $self->{depmod} = @_; }
    return $self->{depmod};
}

sub previous_data
{
    my ($self, $new_data) = @_;

    if (defined $new_data) { $self->{prev} = $new_data; }
    return $self->{prev};
}

sub new_data
{
    my ($self, $new_data) = @_;

    if (defined $new_data) { $self->{new} = $new_data; }
    return $self->{new};
}

sub GetVote
{
   return $_[0]->{vote};
}

sub SetVote
{
   $_[0]->{vote} = $_[1];
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

   $sql = Sql->new($this->dbh);
   require MusicBrainz::Server::Editor;
   return $sql->SelectSingleColumnArray("select name from moderator where privs & " .
                                        &MusicBrainz::Server::Editor::AUTOMOD_FLAG . " > 0 order by name");
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

   $sql = Sql->new($this->dbh);
   if ($sql->Select($query, &DBDefs::MOD_PERIOD_GRACE, $id))
   {
        @row = $sql->NextRow();
        $edit = $this->CreateModerationObject($row[5]);
        if (defined $edit)
        {
            my $artist = new MusicBrainz::Server::Artist($this->{dbh});
            $artist->id($row[4]);
            $artist->name($row[12]);
            $artist->sort_name($row[13]);
            $artist->resolution($row[14]);

            my $moderator = new MusicBrainz::Server::Editor($this->{dbh});
            $moderator->id($row[18]);
            $moderator->name($row[9]);

            my $language = new MusicBrainz::Server::Language($this->{dbh});
            $language->id($row[20]);

			$edit->id($row[0]);
			$edit->table($row[1]);
			$edit->column($row[2]);
			$edit->row_id($row[3]);
			$edit->artist($artist);
			$edit->type($row[5]);
			$edit->previous_data($row[6]);
			$edit->new_data($row[7]);
			$edit->expire_time($row[8]);
			$edit->yes_votes($row[10]);
			$edit->no_votes($row[11]);
			$edit->status($row[15]);
			$edit->SetVote(&ModDefs::VOTE_UNKNOWN);
			$edit->dep_mod($row[17]);
			$edit->moderator($moderator);
			$edit->SetAutomod($row[19]);
			$edit->language($language);
			$edit->open_time($row[21]);
			$edit->close_time($row[22]);
			$edit->expired($row[23]);
			$edit->grace_period_expired($row[24]);
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

	my $sql = Sql->new($self->dbh);
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
	my $sql = Sql->new($self->dbh);

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
	$class->new($this->dbh);
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
		$opts{dbh} = $class->dbh;
		$opts{uid} = $class->moderator->id;
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

		my $this = $editclass->new($opts{dbh} || die "No DBH passed");
		$this->type($this->Type);

        die "No editor passed"
            unless $opts{moderator};

		$this->moderator($opts{moderator});
                $privs = $this->moderator->privs;

		delete @opts{qw( type DBH moderator )};

		$this;
	};

	# Save $privs in $self so that if a nested ->InsertModeration is called,
	# we know what privs to use (see above).
	$this->{_privs_} = $this->moderator->privs;

	# The list of moderations inserted by this call.
	my @inserted_moderations;
	$this->{inserted_moderations} = \@inserted_moderations;

	my $sql = Sql->new($this->dbh);
    my $vertmb = new MusicBrainz;
    $vertmb->Login(db => 'RAWDATA');
    my $vertsql = Sql->new($vertmb->{dbh});

    if (!$notrans)
    {
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
        my $artist = new MusicBrainz::Server::Artist($this->{dbh});
        $artist->id(ModDefs::VARTIST_ID);

		$this->artist($artist);
		$this->table("");
		$this->column("");
		$this->row_id(0);
		$this->dep_mod(0);
		$this->previous_data("");
		$this->new_data("");
		$this->PreInsert(%opts);

		goto SUPPRESS_INSERT if $this->{suppress_insert};
		$this->PostLoad;

		my $level;
		if ($this->type == &Moderation::MOD_CHANGE_RELEASE_QUALITY ||
		    $this->type == &Moderation::MOD_CHANGE_ARTIST_QUALITY)
		{
			$level = Moderation::GetQualityChangeDefs($this->GetQualityChangeDirection);
		}
		else
		{
			$level = Moderation::GetEditLevelDefs($this->quality, $this->type);
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

        croak "No moderator" unless $this->moderator;
        croak "No artist" unless $this->artist;

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
            $this->table, $this->column, $this->row_id,
            $this->previous_data, $this->new_data,
            $this->moderator->id, $this->artist->id, $this->type,
            $this->dep_mod,
            &ModDefs::STATUS_OPEN, sprintf("%d days", $level->{duration}),
            defined $this->language ? $this->language->id : undef
		);

		my $insertid = $sql->GetLastInsertId("moderation_open");
		MusicBrainz::Server::Cache->delete("Moderation-id-range");
		MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
		#print STDERR "Inserted as moderation #$insertid\n";
		$this->id($insertid);

		# Check to see if this moderation should be approved immediately 
		require MusicBrainz::Server::Editor;
		my $ui = MusicBrainz::Server::Editor->new($this->dbh);
		my $isautoeditor = $ui->is_auto_editor($privs);

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
		$autoedit = 0 if ($ui->is_untrusted($privs) and $this->type != &ModDefs::MOD_ADD_PUIDS);

		# If it is autoedit, then approve the edit and credit the editor
		if ($autoedit)
		{
			my $edit = $this->CreateFromId($insertid);
			my $status = $edit->ApprovedAction;

			$sql->Do("UPDATE moderation_open SET status = ?, automod = 1 WHERE id = ?",
				$status,
				$insertid,
			);

			require MusicBrainz::Server::Editor;
			my $user = MusicBrainz::Server::Editor->new($this->dbh);
			$user->CreditModerator($this->{moderator}->id, $status, $autoedit);

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
	my $sql = Sql->new($self->dbh);

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
	my $sql = Sql->new($self->dbh);

	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." and moderator = ?",
        $editor
	);
}

sub OpenModCountAll
{
    my $self = shift;

    my $sql = Sql->new($self->dbh);

    return $sql->SelectSingleValue(
        "SELECT COUNT(*) FROM moderation_open
         WHERE status = ?",
        ModDefs::STATUS_OPEN
    );
}

# This function returns the list of moderations to
# be shown on one moderation page.  It returns an array
# of references to Moderation objects.

sub moderation_list
{
	my ($this, $query, $voter, $index, $num) = @_;
	$query or return SEARCHRESULT_NOQUERY;

	my $sql = Sql->new($this->dbh);

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

        my $artist = new MusicBrainz::Server::Artist($this->{dbh});
        $artist->id($r->{artist});
        $artist->LoadFromId;

        my $moderator = new MusicBrainz::Server::Editor($this->{dbh});
        $moderator->id($r->{moderator});
        $moderator = $moderator->newFromId($moderator->id);

        my $language = MusicBrainz::Server::Language->newFromId($this->{dbh}, $r->{language});

		$edit->id($r->{id});
		$edit->artist($artist);
		$edit->moderator($moderator);
		$edit->table($r->{tab});
		$edit->column($r->{col});
		$edit->type($r->{type});
		$edit->status($r->{status});
		$edit->row_id($r->{rowid});
		$edit->previous_data($r->{prevvalue});
		$edit->new_data($r->{newvalue});
		$edit->yes_votes($r->{yesvotes});
		$edit->no_votes($r->{novotes});
		$edit->dep_mod($r->{depmod});
		$edit->SetAutomod($r->{automod});
		$edit->open_time($r->{opentime});
		$edit->close_time($r->{closetime});
		$edit->expire_time($r->{expiretime});
		$edit->language($language);

		$edit->expired($r->{expired});
		$edit->SetVote($r->{vote});

		push @edits, $edit;
	}

	my $total_rows = $sql->Rows;

	$sql->Finish;

	# Cache editors by name
	require MusicBrainz::Server::Vote;
	my $vote = MusicBrainz::Server::Vote->new($this->dbh);

	for my $edit (@edits)
	{
		# Find vote
		if ($edit->GetVote == VOTE_UNKNOWN and $voter)
		{
			my $thevote = $vote->GetLatestVoteFromUser($edit->id, $voter);
			$edit->SetVote($thevote);
		}
	}

	for (@edits) {
		$_->PostLoad;
		$_->PreDisplay;
	}

	return (SEARCHRESULT_SUCCESS, \@edits, $index + $total_rows);
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
  	my $sql = Sql->new($this->dbh);
   	$sql->Do(
		"UPDATE moderation_open SET status = ? WHERE id = ?",
		$status,
		$this->id,
	);

	MusicBrainz::Server::Cache->delete("Moderation-open-id-range");
	MusicBrainz::Server::Cache->delete("Moderation-closed-id-range");
}

sub RemoveModeration
{
   my ($this, $uid) = @_;
  
   if ($this->status() == &ModDefs::STATUS_OPEN)
   {
		# Set the status to be deleted.  The ModBot will clean it up
		# on its next pass.
		my $sql = Sql->new($this->dbh);
		$sql->Do(
			"UPDATE moderation_open SET status = ?
			WHERE id = ? AND moderator = ? AND status = ?",
	   		&ModDefs::STATUS_TOBEDELETED,
			$this->id,
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
	my $notes = MusicBrainz::Server::ModerationNote->new($self->dbh);
	$notes->newFromModerationId($self->id);
}

sub InsertNote
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->dbh);
	$notes->Insert($self, @_);
}

# Links to the Vote class

sub Votes
{
	my $self = shift;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->dbh);
	$votes->newFromModerationId($self->id);
}

sub VoteFromUser
{
	my ($self, $uid) = @_;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->dbh);
	# The number of votes per mod is small, so we may as well just retrieve
	# all votes for the mod, then find the one we want.
	my @votes = $votes->newFromModerationId($self->id);
	# Pick the most recent vote from this user
	(my $thevote) = reverse grep { $_->GetUserId == $uid } @votes;
	$thevote;
}

sub FirstNoVote
{
	my ($self, $voter_uid) = @_;

	require MusicBrainz::Server::Editor;
	my $editor = MusicBrainz::Server::Editor->newFromId($self->{dbh}, $self->moderator->id);
	my $voter = MusicBrainz::Server::Editor->newFromId($self->{dbh}, $voter_uid);
	
	return;

	require UserPreference;
	my $send_mail = UserPreference::get_for_user('mail_on_first_no_vote', $editor);
	$send_mail or return;

	my $url = "http://" . &DBDefs::WEB_SERVER . "/show/edit/?editid=" . $self->id;

	my $body = <<EOF;
Editor '${\ $voter->name }' has voted against your edit #${\ $self->id }.
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
		References	=> '<edit-'.$self->id.'@'.&DBDefs::WEB_SERVER.'>',
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

	my $sql = Sql->new($self->dbh);

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

	my $sql = Sql->new($self->dbh);

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

sub template
{
    my ($self) = @_;

    my $comp = ref $self;
    $comp =~ s/.*::MOD_(.*)/$1/;

    return lc $comp;
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
# and its fields have been set via ->previous_data, ->new_data etc.  The class should
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
        my $table = lc $this->table;

        my $sql = Sql->new($this->dbh);
        $sql->Do(
            "UPDATE $table SET modpending = modpending + ? WHERE id = ?",
            $adjust,
            $this->row_id,
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
