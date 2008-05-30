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
#   $Id$
#____________________________________________________________________________
#
</%perl>
<%args>

	$offset => undef
	$page => undef
	$pagesize => undef

	$report_title => "Releases to convert to Multiple Artists"

</%args>
<%perl>

	use MusicBrainz::Server::PagedReport;
	use File::Basename qw( dirname );
	my $rep = MusicBrainz::Server::PagedReport->Load(
		dirname($m->current_comp->source_file) . "/report"
	);

	$pagesize = 10
		unless MusicBrainz::Server::Validation::IsNonNegInteger($pagesize)
		and $pagesize > 0 and $pagesize <= 100000;

	$offset = ($page-1) * $pagesize
		if not defined $offset
		and MusicBrainz::Server::Validation::IsNonNegInteger($page)
		and $page;

	$offset = 0
		unless MusicBrainz::Server::Validation::IsNonNegInteger($offset)
		and $offset < $rep->Records;

	$rep->Seek($offset);

</%perl>

<& /comp/sidebar-notitle, pagetitle => $report_title  &>

	<& /comp/tablebegin, title => $report_title &>
		<ul>
			<li>This report aims to identify releases which need converting to
				"multiple artists". Currently it does this by looking for releases
				where every track contains "/" or "-".</li>
			<li>Total releases found: <% $rep->Records %></li>
			<li>Generated <% $m->comp('/comp/datetime', $rep->Time) %></li>
		</ul>

% 	if ($rep->Records)
%	{

		<& /comp/browse/pageselector,
			numitems => $rep->Records,
			numlinks => 6,
			snaptoend => 2,
			pagesize => $pagesize,
			offset => $offset,
			url => $r->uri,
			args => { pagesize => $pagesize },
		&>

% 	}

	<& /comp/tableend &>

<%perl>

 	if ($rep->Position < $rep->Records)
	{
		my $lastartist = 0;
		my $n = 0;

		for my $i (0 .. $pagesize-1)
		{
			my $row = $rep->Get or last;

			if ($row->{artist_id} != $lastartist)
			{
				my $ar = MusicBrainz::Server::Artist->new(undef);
				$ar->SetId($row->{artist_id});
				$ar->SetMBId($row->{artist_mbid});
				$ar->SetName($row->{artist_name});
				$ar->SetSortName($row->{artist_sortname});
				$ar->SetResolution($row->{artist_resolution});
				$ar->SetModPending($row->{artist_modpending});

				$m->comp("/comp/artisttitle", artist => $ar, showlinks => 0, showmodlinks => 0);
			}

</%perl>

		<& /comp/linkrelease, id => $row->{'album_id'}, name => $row->{'album_name'}, strong => 0 &>
		<ul style="margin-top: 2px">

%			for my $track (@{ $row->{tracks} })
%			{

			<li><% $track->{track_seq} %>.&nbsp; <% $track->{track_name} %>

%			}

		</ul>

%			$lastartist = $row->{artist_id};
%		}


		<& /comp/tablebegin, title => $report_title &>
			<& /comp/browse/pageselector,
				numitems => $rep->Records,
				numlinks => 6,
				snaptoend => 2,
				pagesize => $pagesize,
				offset => $offset,
				url => $r->uri,
				args => { pagesize => $pagesize },
			&>
		<& /comp/tableend &>

%	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
