#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
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

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

# Make sure these settings are right. If you are using Postgres with a
# database called 'musicbrainz' then you shouldn't need to change the next line
use constant DSN 	=>	'dbi:Pg:dbname=musicbrainz';

# Insert the name of the database here
use constant DB_NAME 	=>	'musicbrainz';
# Insert the user name that has access to the database listed above
use constant DB_USER 	=>	'postgres';
# Insert the password of the user from above
use constant DB_PASSWD 	=>	'';

# Set this value if you want to have a read-only server.
use constant DB_READ_ONLY => 0;

# Set this value to a message that you'd like to display to users when
# they attempt to log or otherwise modify the database.
use constant DB_READ_ONLY_MESSAGE => qq/This server is temporarily in 
read-only mode for database maintainance./;

# Set this value if this is a staging server
use constant DB_STAGING_SERVER => 1;

# This defines the version of the server
use constant VERSION => "1.0.0-preX";

# Defines the number of seconds before the votes on a 
# modification are evaluated
#use constant MOD_PERIOD => 604800;   # 1 week
#use constant MOD_PERIOD => '2 days';   # 2 days
use constant MOD_PERIOD => '1 second';   

# Defines the number of unanimous votes required to pass a mod early
use constant NUM_UNANIMOUS_VOTES => 5;

# Do not set this unless you are running on a test server. This setting
# Allows a person to vote on ther own modifications. It should be used
# for testing purposes only.
use constant ALLOW_SELF_VOTE => 0;

# These two defines specify where to create the Apache::Session files
# that are needed for HTTP session persistence.
use constant LOCK_DIR => "/home/httpd/musicbrainz/locks";
use constant SESSION_DIR => "/home/httpd/musicbrainz/sessions";
use constant CACHE_DIR => "/home/httpd/musicbrainz/mason/cache";

use constant DEBUG_LOG => "/tmp/musicbrainz-debug.log";

# The host names of the HTML / RDF parts of the server.
# To use a port number other than 80, add it like so: "myhost:8000"
use constant WEB_SERVER => "www.musicbrainz.org";
use constant RDF_SERVER => "mm.musicbrainz.org";

1;
