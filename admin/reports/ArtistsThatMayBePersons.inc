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
#   This report lists CDTocs which only differ by their leadout offset
#   (Incorrect disc IDs submitted by Windows clients )
#
#   $Id: BadWin32CDTOCs.inc 8672 2006-11-21 13:52:39Z luks $
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

	$pagesize = 25
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

<& /comp/sidebar-notitle, pagetitle => "Artist that may be persons" &>

	<& /comp/tablebegin, title => "Artists that may be persons" &>
		<ul>
			<li>This report lists artists that are <em>unknown</em> or <em>group</em>, 
			    but may be <em>person</em>, based on band "collaboration" advanced relationships.</li>
			<li>Total artists found: <% $rep->Records %></li>
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
				<th>Artist</th>
				<th>Type</th>
			</tr>
		</thead>

<%perl>

		my $n = 0;
		for my $i (0 .. $pagesize-1)
		{
			my $row = $rep->Get or last;
			$row->{type} = $row->{type} ? "group" : "unknown";

			</%perl>
			<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
				<td>
					<& /comp/linkartist, id => $row->{'id'}, name => $row->{'name'} &></td>
				<td>
					<% $row->{'type'} %></td>
			</tr>

%		}

	</table>

%	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
