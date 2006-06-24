<%perl>
	# -----------------------------------------------------------------------------
	#                               Musicbrainz.org
	#                        Copyright (c) 2001 Robert Kaye
	# -----------------------------------------------------------------------------
	#  This software is provided "as is", without warranty of any kind, express or
	#  implied, including  but not limited  to the warranties of  merchantability,
	#  fitness for a particular purpose and noninfringement. In no event shall the
	#  authors or  copyright  holders be  liable for any claim,  damages or  other
	#  liability, whether  in an  action of  contract, tort  or otherwise, arising
	#  from,  out of  or in  connection with  the software or  the  use  or  other
	#  dealings in the software.
	#
	#  GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
	#  Permits anyone the right to use and modify the software without limitations
	#  as long as proper  credits are given  and the original  and modified source
	#  code are included. Requires  that the final product, software derivate from
	#  the original  source or any  software  utilizing a GPL  component, such  as
	#  this, is also licensed under the GPL license.
	# -----------------------------------------------------------------------------
	#
	# Summary:
	# -----------------------------------------------------------------------------
	# Render a list of releases with their release artists.
	#
	# $Id$
	#
</%perl>
<%args>

	$reportdir => undef
	$offset => undef
	$page => undef
	$pagesize => undef

</%args>
<%perl>

	use MusicBrainz::Server::PagedReport;
	use File::Basename qw( dirname );

	$reportdir = dirname($m->caller(1)->source_file) unless defined $reportdir;
	my $rep = MusicBrainz::Server::PagedReport->Load("$reportdir/report");

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

	<p>Report generated: <% $m->comp('/comp/datetime', $rep->Time) %></p>
	<p>Total releases found: <% $rep->Records %></p>

% 	if ($rep->Records)
%	{

	<& /comp/framedboxbegin, width=>"100%" &>
		<& /comp/pageselector,
			numitems => $rep->Records,
			numlinks => 6,
			snaptoend => 2,
			pagesize => $pagesize,
			offset => $offset,
			url => $r->uri,
			args => { pagesize => $pagesize },
		&>
	<& /comp/framedboxend &>

	<br />
	<br />

% 	}

% 	if ($rep->Position < $rep->Records)
%	{

	<table id="Report" class="SpacedRows SpacedColumns TopAlignCells">
		<tr>
			<th>Artist Name</th>
			<th>Release Name</th>
		</tr>

%		for my $i (0 .. $pagesize-1)
%		{
%			my $row = $rep->Get or last;

		<tr <% (++$i%2) ? 'class="shade"' : '' |n %>>
			<td>
				<& /comp/linkartist, id => $row->{artist_id}, name => $row->{artist_name} &></td>
			<td>
				<& /comp/linkrelease, id => $row->{album_id}, name => $row->{album_name} &></td>
		</tr>

% 		}

	</table>

	<br />
	<br />

	<& /comp/framedboxbegin, width=>"100%" &>
		<& /comp/pageselector,
			numitems => $rep->Records,
			numlinks => 6,
			snaptoend => 2,
			pagesize => $pagesize,
			offset => $offset,
			url => $r->uri,
			args => { pagesize => $pagesize },
		&>
	<& /comp/framedboxend &>

% 	}

%# vi: set ts=4 sw=4 ft=mason :
