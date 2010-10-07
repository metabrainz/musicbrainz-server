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
#   This report lists tracks which do not conform to FeaturingArtistStyle.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Track names which do not conform to FeaturingArtistStyle" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Track names which do not conform to FeaturingArtistStyle!;

	$ARGS{"report_text"} =
		qq!	This report lists broken tracks containing featuring artists that do not
			follow the style guide. For some tracks (those with a <em>Suggest</em>
			link) a suggestion exists which is used as a default in the
			<em>edit track</em> dialog. You may still need the <em>Guess Case</em>
			button or manual intervention, however.!;

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
