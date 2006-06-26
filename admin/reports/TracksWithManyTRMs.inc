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
	# This report lists tracks with at more than 10 TRMs.
	#
	# $Id$
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

<& /comp/sidebar-notitle, pagetitle => "Tracks with many TRMs" &>

	<& /comp/tablebegin, title => "Tracks with many TRMs" &>
		<ul>
			<li>This report lists tracks with at least 10 TRMs.</li>
			<li>Total tracks found: <% $rep->Records %></li>
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
			<th>Artist Name</th>
			<th>Track Name</th>
			<th>TRMs</th>
		</tr>

% 		my $n = 0;
%		for my $i (0 .. $pagesize-1)
%		{
%			my $row = $rep->Get or last;

		<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
			<td>
				<& /comp/linkartist,
					id => $row->{'artist_id'},
					name => $row->{'artist_name'},
					sortname => $row->{'artist_sortname'},
					resolution => $row->{'artist_resolution'},
				&></td>
			<td>
				<& /comp/linktrack,
					id => $row->{'track_id'},
					name => $row->{'track_name'}
				&></td>
			<td style="text-align: right">
				<% $row->{trmcount} %></td>
		</tr>

% 		}

	</table>

%	}

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
