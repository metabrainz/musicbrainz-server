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
                                                                               
package ModDefs;

BEGIN { require 5.6.1 }

use strict;

use constant ANON_MODERATOR              => 1;
use constant FREEDB_MODERATOR            => 9999;

use constant TYPE_NEW                    => 1;
use constant TYPE_VOTED                  => 2;
use constant TYPE_MINE                   => 3;

use constant MOD_EDIT_ARTISTNAME         => 1;
use constant MOD_EDIT_ARTISTSORTNAME     => 2;
use constant MOD_EDIT_ALBUMNAME          => 3;
use constant MOD_EDIT_TRACKNAME          => 4;
use constant MOD_EDIT_TRACKNUM           => 5;
use constant MOD_MERGE_ARTIST            => 6;
use constant MOD_ADD_TRACK               => 7;
use constant MOD_MOVE_ALBUM              => 8;
use constant MOD_SAC_TO_MAC              => 9;
use constant MOD_CHANGE_TRACK_ARTIST     => 10;
use constant MOD_REMOVE_TRACK            => 11;
use constant MOD_REMOVE_ALBUM            => 12;
use constant MOD_MAC_TO_SAC              => 13;
use constant MOD_REMOVE_ARTISTALIAS      => 14;
use constant MOD_ADD_ARTISTALIAS         => 15;
use constant MOD_ADD_ALBUM               => 16;
use constant MOD_ADD_ARTIST              => 17;
use constant MOD_ADD_TRACK_KV            => 18;
use constant MOD_REMOVE_ARTIST           => 19;
use constant MOD_REMOVE_DISKID           => 20;
use constant MOD_MOVE_DISKID             => 21;

use constant STATUS_OPEN                 => 1;
use constant STATUS_APPLIED              => 2;
use constant STATUS_FAILEDVOTE           => 3;
use constant STATUS_FAILEDDEP            => 4;
use constant STATUS_ERROR                => 5;
use constant STATUS_FAILEDPREREQ         => 6;
use constant STATUS_EVALNOCHANGE         => 7;
use constant STATUS_DELETED              => 8;

1;
