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
#   This report lists possibly duplicate artists.
#
#   $Id$
#____________________________________________________________________________
#
</%perl>
<%args>

	$offset => undef
	$page => undef
	$pagesize => undef

	$report_title => "Possibly duplicate artists"

</%args>
<%perl>

	use MusicBrainz::Server::Artist;
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

	my $mb = $m->comp('/comp/dblogin');

</%perl>

<& /comp/sidebar-notitle, pagetitle => $report_title &>

	<& /comp/tablebegin, title => $report_title &>
		<ul>
			<li>This report aims to identify artists with very similar names,
				which might indicate that the artists need to be merged.</li>
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

	<table class="listing">
		<tr class="header">
			<td class="left padright">Artist Name</td>
			<td class="left padright">Artist Sortname</td>
			<td class="right padright">Releases</td>
			<td class="right padright">Tracks</td>
		</tr>

% 		for my $i (0 .. $pagesize-1)
%		{
%  			my $dupelist = $rep->Get or last;

%			my $j = 0;
% 			foreach my $row ( @$dupelist )
%			{
% 				my $ar = MusicBrainz::Server::Artist->new($mb->{dbh});
% 				$ar->SetId( $row->{artist_id} );
% 				$ar->LoadFromId();

		<tr class="<% $j++ % 2 == 0 ? "even" : "odd" %>">
			<td class="left padright">
				<span <% ($ar->GetModPending) ? 'class="mp"' : '' |n %>>
				<& /comp/linkartist, artist => $ar, strong => 0 &></td>
				</span>
			<td class="left padright">
				<% $ar->GetSortName %></td>
			<td class="right padright">
				<% $row->{num_albums} %></td>
			<td class="right padright">
				<% $row->{num_tracks} %></td>
		</tr>

% 			}

		<tr><td>&nbsp;</td></tr>

% 		}

	</table>

	<br />
	<br />

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

% 	}


<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
