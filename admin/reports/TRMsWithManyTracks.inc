%# vi: set ts=2 sw=2 ft=mason :
<%args>
$offset => undef
$page => undef
$pagesize => undef
</%args>
<%perl>

use MusicBrainz::Server::PagedReport;
my $rep = MusicBrainz::Server::PagedReport->Load(
	&DBDefs::HTDOCS_ROOT . "/reports/TRMsWithManyTracks"
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

<& /comp/sidebar, title => "TRMs with at least 5 tracks",
	head => '
<style type="text/css">
	tr.odd { background-color: #eee; }
	td.link { text-align: center; white-space: nowrap; }
</style>
' &>

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<p>
    This report lists TRMs which resolve to at least 5 tracks.
</p>

<p>Total TRMs found: <% $rep->Records %></p>

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

<table class="SpacedRows SpacedColumns TopAlignCells">
	<caption>TRMs with at least 5 tracks</caption>
	<thead>
		<tr>
			<th>TRM</th>
			<th>Track</th>
			<th>Length</th>
			<th>Artist</th>
		</tr>
	</thead>
	<%perl>
	for my $i (0 .. $pagesize-1)
	{
		my $row = $rep->Get or last;
		my $tracks = $row->{tracks};

		my $first = 1;

		for my $track (@{ $row->{'tracks'} })
		{
			</%perl>
			<tr>
% if ($first) {
				<td rowspan="<% scalar @$tracks %>">
					<a href="/showtrm.html?trm=<% $row->{'trm'} %>"><% $row->{'trm'} %></a>
					<br>
					<br><% $row->{'lookupcount'} %> lookups
					<br><% scalar @$tracks %> tracks
				</td>
% }

				<td><a href="/showtrack.html?trackid=<% $track->{'track_id'} %>"><% $track->{'track_name'} %></a></td>
				<td><% Track::FormatTrackLength($track->{'length'}) %></td>
				<td><a href="/showartist.html?artistid=<% $track->{'artist_id'} %>"><% $track->{'artist_name'} %></a></td>
			</tr>

			<%perl>
			$first = 0;
		}
		$m->out("<tr><td>&nbsp;</td></tr>\n");
	}
</%perl>

</table>

% }

<& /comp/footer &>
