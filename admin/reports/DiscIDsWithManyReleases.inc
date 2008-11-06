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
#   This report lists disc IDs attached to multiple releases.
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

	$pagesize = 100
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

<& /comp/sidebar-notitle, pagetitle => "Disc IDs attached to multiple releases" &>

	<& /comp/tablebegin, title => "Disc IDs attached to multiple releases" &>
		<ul>
			<li>This report lists disc IDs which are attached to multiple releases. 
				Disc IDs attached to multiple releases where the releases are joined by a <& /comp/linkdoc, "TranslationTransliterationRelationshipType", "translation or transclusion relationship" &> are excluded.</li>
			<li>Total disc IDs found: <% $rep->Records %></li>
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
				<th>Disc ID</th>
				<th>Artist</th>
				<th>Release</th>
			</tr>
		</thead>

<%perl>
		my $prev = 0;

		for my $i (0 .. $pagesize-1)
		{
			my $row = $rep->Get or last;

 			if ($prev ne $row->{'disc_id'})
			{
</%perl>
				<tr>
					<td colspan="3" class="head">
						<a href="/show/cdtoc/?cdtocid=<% $row->{'cdtoc_id'} %>"><% $row->{'disc_id'} %></a>
					</td>
				</tr>
%			}

			<tr>
				<td>&nbsp;</td>
				<td>
					<& /comp/linkartist,
						id => $row->{'artist_id'},
						name => $row->{'artist_name'},
						sortname => $row->{'artist_sortname'},
						resolution => $row->{'artist_resolution'},
						strong => 0
					&>
				</td>
				<td>
					<& /comp/linkrelease,
						id => $row->{'release_id'},
						name => $row->{'release_name'},
						strong => 0
					&>
				</td>
			</tr>
<%perl>
			$prev = $row->{'disc_id'};
		}
</%perl>
	</table>
%	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
