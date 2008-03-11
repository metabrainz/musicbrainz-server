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
#   This report lists PUIDs which are attached to many tracks.
#
#   $Id: PUIDsWithManyTracks.inc 8501 2006-09-29 22:48:24Z robert $
#____________________________________________________________________________
#
</%perl>
<%args>

	$offset => undef
	$page => undef
	$pagesize => undef

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

<& /comp/sidebar-notitle, pagetitle => "PUIDs with at least 10 tracks" &>

	<& /comp/tablebegin, title => "PUIDs with at least 10 tracks" &>
		<ul>
			<li>This report lists PUIDs which resolve to at least 10 tracks.</li>
			<li>Total PUIDs found: <% $rep->Records %></li>
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

% 	if ($rep->Position < $rep->Records)
%	{

	<table id="Report" class="SpacedRows SpacedColumns TopAlignCells">
		<thead>
			<tr>
				<th>PUID</th>
				<th>Artist</th>
				<th>Track</th>
				<th>Length</th>
			</tr>
		</thead>

<%perl>
		for my $i (0 .. $pagesize-1)
		{
			my $row = $rep->Get or last;
			my $tracks = $row->{tracks};

			my $first = 1;
			my $n = 1;

			for my $track (@{ $row->{'tracks'} })
			{

</%perl>

% 				if ($first)
%				{

			<tr>
				<td colspan="4" class="head">
					<a href="/show/puid/?puid=<% $row->{'puid'} %>"><% $row->{'puid'} %></a>
					(<% $row->{'lookupcount'} %> lookups, <% scalar @$tracks %> tracks)
				</td>
			</tr>

% 					$n = 1;
% 				}

			<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
				<td>&nbsp;</td>
				<td>
					<& /comp/linkartist,
						id => $track->{'artist_id'},
						name => $track->{'artist_name'},
						sortname => $track->{'artist_sortname'},
						resolution => $track->{'artist_resolution'},
						strong => 0
					&></td>
				<td>
					<& /comp/linktrack,
						id => $track->{'track_id'},
						name => $track->{'track_name'},
						strong => 0
					&></td>
				<td>
					<% MusicBrainz::Server::Track::FormatTrackLength($track->{'length'}) %></td>
			</tr>

<%perl>
				$first = 0;
			}
			$m->out("<tr><td>&nbsp;</td></tr>\n");
		}

</%perl>

	</table>

% 	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
