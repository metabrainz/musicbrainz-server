%# vi: set ts=2 sw=2 ft=mason :
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

<& /comp/sidebar, title => 'Tracks with many TRMs',
	head => '
<style type="text/css">
	td.trm { text-align: right; }
</style>
' &>

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<p>
	This report lists tracks with at least 10 TRMs.
</p>

<p>Total tracks found: <% $rep->Records %></p>

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
	<tr>
		<th>Artist Name</th>
		<th>Track Name</th>
		<th>TRMs</th>
	</tr>

% my $n = 0;
%	for my $i (0 .. $pagesize-1) {
%		my $row = $rep->Get or last;

	<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
		<td><a href="/showartist.html?artistid=<% $row->{artist_id} %>"
				><% $row->{artist_name} %></a></td>
		<td><a href="/showtrack.html?trackid=<% $row->{track_id} %>"
				><% $row->{track_name} %></a></td>
		<td class="trm"><% $row->{trmcount} %></td>
	</tr>
% }

</table>

% }

<& /comp/footer &>
