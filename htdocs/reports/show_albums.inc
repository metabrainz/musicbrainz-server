%# vi: set ts=2 sw=2 ft=mason :
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
		<th>Album Name</th>
	</tr>

%	for my $i (0 .. $pagesize-1) {
%		my $row = $rep->Get or last;

	<tr <% (++$i%2) ? 'class="shade"' : '' |n %>>
		<td><a href="/showartist.html?artistid=<% $row->{artist_id} %>"
				><% $row->{artist_name} %></a></td>
		<td><a href="/showalbum.html?albumid=<% $row->{album_id} %>"
				><% $row->{album_name} %></a></td>
	</tr>

% }

</table>

% }

<p> Generated <% $m->comp('/comp/datetime', $rep->Time) %> </p>
