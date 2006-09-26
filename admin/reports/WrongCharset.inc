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
#   This report lists tracks which might have a wrong encoding set.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Tracks which are probably encoded using the wrong character set" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Tracks which are probably encoded using the wrong character set!;

	$ARGS{"report_text"} = sprintf
		qq!	When data is imported from FreeDB, it is meant to be in the iso-8859-1
			("Latin-1") character set. However, if the data was actually in a
			different character set, for example the Chinese "Big5" set, then the data
			which ends up in MusicBrainz is corrupted. It is not worthless, though,
			because with a little effort the correct character set can be
			deduced, and the existing data converted into the correct form.

			All tracks which look like they might have been encoded using the wrong
			character set are listed below. We are looking specifically for tracks
			which only contain characters from the latin-1 character set, but which
			do not contain any of A-Z a-z 0-9. Finally we ignore a few track names
			which fit this category but which occur very often (e.g. ".", "?", "???" etc.)

			For more information, please read the %s.!

		, $m->scomp("/comp/linkdoc", "MisencodingFAQ", "Misencoding FAQ");

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
