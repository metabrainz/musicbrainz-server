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
#   This report lists Releases with duplicate TRMs for different tracks.
#
#   $Id$
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
	  unless MusicBrainz::IsNonNegInteger($pagesize)
	  and $pagesize > 0 and $pagesize <= 100000;

	$offset = ($page-1) * $pagesize
	  if not defined $offset
	  and MusicBrainz::IsNonNegInteger($page)
	  and $page;

	$offset = 0
	  unless MusicBrainz::IsNonNegInteger($offset)
	  and $offset < $rep->Records;

	$rep->Seek($offset);

</%perl>

<& /comp/sidebar-notitle, pagetitle => "Releases with duplicate TRMs for different tracks" &>

	<& /comp/tablebegin, title => "Releases with duplicate TRMs for different tracks" &>
		<ul>
			<li>This report lists TRMs that match for more than one track of a release.</li>
			<li>Total TRMs found: <% $rep->Records %></li>
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
		<tr>
			<th colspan="2">Artist</th>
			<th>Release</th>
			<th/>
		</tr>
		<tr>
			<th>&nbsp;</th>
			<th colspan="2">TRM</th>
			<th width="5%">Count</th>
		</tr>

%		my $n = 0;
%		for my $i (0 .. $pagesize-1)
%		{
%			my $row = $rep->Get or last;

		<tr>
			<td colspan="2" class="head" width="45%">
				<& /comp/linkartist, id => $row->{'artist_id'}, name => $row->{'artist_name'},
					sortname => $row->{'artist_sortname'}, resolution => $row->{'artist_resolution'},
					strong => 0 &></td>
			<td colspan="2" class="head">
				<& /comp/linkrelease, id => $row->{'album_id'}, name => $row->{'album_name'},
					strong => 0 &></td>
		</tr>

%			$n = 1;
%			for my $trm (@{ $row->{'trms'} })
%			{

		<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
			<td width="5%"></td>
			<td colspan="2" align="center"><a href="/show/trm/?trm=<% $trm->{'trm'} %>"><% $trm->{'trm'} %></a></td>
			<td align="center"><% $trm->{'freq'} %></td>
		</tr>

%			}

		<tr><td colspan="4">&nbsp;</td></tr>

%		}

	</table>

%	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
