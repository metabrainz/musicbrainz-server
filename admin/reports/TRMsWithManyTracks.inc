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
	# This report lists TRMs which are attached to many tracks.
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

	$pagesize = 10
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

<& /comp/sidebar-notitle, pagetitle => "TRMs with at least 10 tracks" &>

	<& /comp/tablebegin, title => "TRMs with at least 10 tracks" &>
		<ul>
			<li>This report lists TRMs which resolve to at least 10 tracks.</li>
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
		<thead>
			<tr>
				<th>TRM</th>
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
					<a href="/showtrm.html?trm=<% $row->{'trm'} %>"><% $row->{'trm'} %></a>
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
					&></td>
				<td>
					<& /comp/linktrack,
						id => $track->{'track_id'},
						name => $track->{'track_name'}
					&></td>
				<td>
					<% Track::FormatTrackLength($track->{'length'}) %></td>
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
