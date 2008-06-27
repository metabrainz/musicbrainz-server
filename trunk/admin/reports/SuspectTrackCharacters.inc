<%perl>
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
#____________________________________________________________________________
#
#   This report lists track with questionable characters in them.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Questionable Characters in tracks" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Questionable Characters in tracks!;

	$ARGS{"report_text"} =
		qq!	All tracks which contain *, %, $, @, {, }, [, ], ;, ", &lt;, or &gt;
			are listed below:!;

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
