#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
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

# This script can either be invoked as "./admin/depend.pl" (main Perl
# program), or it can be "require"d by the mod_perl server.

BEGIN
{
	unless (caller)
	{
		require FindBin;
		require lib;
		no warnings 'once';
		lib->import("$FindBin::Bin/../cgi-bin");
	}
}

# Check for various dependencies.

# MusicBrainz requires that the "en_US.UTF-8" locale is installed.
# Check that this locale is available.
# (We check this here because, unlike most other dependencies, this one can go
# unnoticed for quite a while during the operation of a server).
eval { require POSIX; new LocaleSaver(&POSIX::LC_CTYPE, "en_US.UTF-8"); 1 }
	or die "setlocale() failed.  Is the en_US.UTF-8 locale installed?";

1;
# eof depend.pl
