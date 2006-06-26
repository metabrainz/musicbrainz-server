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
	# This report lists Releases with duplicate TRMs for different tracks.
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
