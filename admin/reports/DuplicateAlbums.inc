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
#   This report lists possibly duplicate releases.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Possibly duplicate releases (from MusicMagic database)" &>

<%perl>

	my $mtime = $m->comp("./TIMESTAMP");
	my $supplydate = $m->scomp('/comp/datetime', $mtime);

	$ARGS{"report_title"} =
		qq!Possibly duplicate releases (from MusicMagic database)!;

	$ARGS{"report_text"} =
		qq! This report lists releases that may be duplicates. The data for this
			report has been contributed by Wendell T. Hicken from
			<a href="http://music.predixis.com/">Predixis</a> using the MusicMagic
			database. Thanks\!
			<br />
			Data last supplied: $supplydate!;

	$m->comp("/reports/show_album_duplicates.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
