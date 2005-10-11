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

<& /comp/sidebar, title => "TRMs with at least 10 tracks" &>

<p>
    This report lists TRMs which resolve to at least 10 tracks.
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
% if ($first) {
			<tr>
				<td colspan="4" class="head">
					<a href="/showtrm.html?trm=<% $row->{'trm'} %>"><% $row->{'trm'} %></a>
					(<% $row->{'lookupcount'} %> lookups, <% scalar @$tracks %> tracks)
				</td>
			</tr>
% $n = 1;
% }

			<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
				<td></td>
				<td><a href="/showartist.html?artistid=<% $track->{'artist_id'} %>"><% $track->{'artist_name'} %></a></td>
				<td><a href="/showtrack.html?trackid=<% $track->{'track_id'} %>"><% $track->{'track_name'} %></a></td>
				<td><% Track::FormatTrackLength($track->{'length'}) %></td>
			</tr>

			<%perl>
			$first = 0;
		}
		$m->out("<tr><td>&nbsp;</td></tr>\n");
	}
</%perl>

</table>

% }

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<& /comp/footer &>
