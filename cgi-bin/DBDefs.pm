#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 1998 Robert Kaye
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
                                                                               
package DBDefs;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

# Make sure these settings are right. If you are using MySQL with a
# database called 'cdindex' then you shouldn't need to change the next line
use constant DSN 	=>	'dbi:mysql:musicbrainz';

# Insert the user name that has access to the database listed above
use constant DB_USER 	=>	'musicbrainz';
# Insert the password of the user from above
use constant DB_PASSWD 	=>	'';

# Set this to 1 if you would like this server to handle lyrics.
# Please note that this is likely to get you into legal trouble. Please
# be aware of the local laws if you intend to run a lyrics server.
use constant USE_LYRICS => 1;

# This defines the version of the server
use constant VERSION => "1.0.0-pre2";

# Defines the number of seconds before the votes on a 
# modification are evaluated
#use constant MOD_PERIOD => 604800;   # 1 week

# Defines the number of unanimous votes required to pass a mod early
use constant NUM_UNANIMOUS_VOTES => 5;
