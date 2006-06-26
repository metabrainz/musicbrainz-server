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
	# This report lists CDTocs which only differ by their leadout offset
	# (Incorrect disc IDs submitted by Windows clients )
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

<& /comp/sidebar, title => "Incorrect DiscIDs submitted by Windows clients " &>

<p>
    This report lists pairs of CD TOCs which are identical except for the
    leadout offset, which differs by exactly two seconds.
</p>

<p>Pairs found: <% $rep->Records %></p>

% if ($rep->Records) {
<& /comp/framedboxbegin, width=>"100%" &>
<& /comp/pageselector,
	numitems	=> $rep->Records,
  numlinks	=> 6,
  snaptoend	=> 2,
  pagesize	=> $pagesize,
  offset		=> $offset,
	url				=> $r->uri,
	args			=> { pagesize => $pagesize },
	&>
<& /comp/framedboxend &>
<br><br>
% }

% if ($rep->Position < $rep->Records) {

<table id="Report" class="SpacedRows SpacedColumns TopAlignCells">
	<thead>
		<tr>
			<th></th>
			<th colspan="2">Shorter CD TOC</th>
			<th colspan="2">Longer CD TOC</th>
		</tr>
		<tr>
			<th>Info</th>
			<th>Artist</th>
			<th>Album</th>
			<th>Artist</th>
			<th>Album</th>
		</tr>
	</thead>
	<%perl>
	my $n = 0;
	for my $i (0 .. $pagesize-1)
	{
		my $row = $rep->Get or last;

		my $summary = (
			($row->{'album_id_1'} == $row->{'album_id_2'})
			? "same album"
			: ($row->{'artist_name_1'} eq $row->{'artist_name_2'}
				and $row->{'album_name_1'} eq $row->{'album_name_2'})
			? "same name"
			: "other"
		);

		</%perl>
		<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
			<td><% $summary %></td>
			<td><a href="/showartist.html?artistid=<% $row->{'artist_id_1'} %>"><% $row->{'artist_name_1'} %></a></td>
			<td><a href="/albumdetail.html?albumid=<% $row->{'album_id_1'} %>&amp;disciddetail=both"><% $row->{'album_name_1'} %></a></td>
			<td><a href="/showartist.html?artistid=<% $row->{'artist_id_2'} %>"><% $row->{'artist_name_2'} %></a></td>
			<td><a href="/albumdetail.html?albumid=<% $row->{'album_id_2'} %>&amp;disciddetail=both"><% $row->{'album_name_2'} %></a></td>
		</tr>
		<%perl>

	}
</%perl>

</table>

% }

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
