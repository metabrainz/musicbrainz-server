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

<& /comp/sidebar, title => "Broken Win32 CD TOCs" &>

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
