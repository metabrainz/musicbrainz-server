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
#   This report lists releases where the number of tracks on the release is
#   different from the number of tracks specified by the disc ID.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>

<& /comp/sidebar-notitle, pagetitle => qq!Releases with "Broken" Disc IDs! &>

<%perl>

	$ARGS{"report_title"} =
		qq!Releases with "Broken" Disc IDs!;

	$ARGS{"report_text"} = qq!
		This report identifies releases with disc IDs, where the tracks
		on the release do not match with the disc ID.

		For example, if the disc ID says that there are four tracks,
		then this report checks that the release has four tracks, and
		that the first track is track 1, and the last track is track 4.
		Note that it <emi>doesn't</em> check all the intervening track
		numbers; for example, if the tracks on the release were
		numbered 1, 2, 2, 4, then this report would <em>not</em> detect
		that.  However by using both this report and the <a
		href="/reports/generated/DuplicateTrackNumbers">duplicate track
		numbers</a> report it should be possible to identify and fix
		all track/disc ID problems.!;

	$m->comp("/reports/show_albums.inc", %ARGS);

</%perl>

<& /comp/footer &>
