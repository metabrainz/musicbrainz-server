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

<& /comp/sidebar, title => "Track names which should say '(feat. artist)'",
	head => '
<style type="text/css">
	tr.odd { background-color: #eee; }
	td.link { text-align: center; white-space: nowrap; }
</style>
' &>

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<p>
    This report lists broken tracks containing featuring artists that don't
    follow the style guide. For some tracks (those with a <em>Suggest</em>
    link) a suggestion exists which is used as a default in the
    <em>edit track</em> dialog. You may still need the <em>Guess Case</em>
    button or manual intervention, however.
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

<table class="SpacedRows SpacedColumns TopAlignCells">
	<tr>
		<th>Artist Name</th>
		<th>Track Name</th>
		<th>&nbsp;</th>
	</tr>

%	my $lastartist = 0;
% my $n = 0;
%	for my $i (0 .. $pagesize-1) {
%		my $row = $rep->Get or last;

% if ($row->{artist_id} != $lastartist) {
	<tr <% (++$n%2) ? 'class="odd"' : '' |n %>>
		<td colspan="3" style="font-weight: bold; padding-top: 0.5em; padding-bottom: 0.5em">
			<a href='/showartist.html?artistid=<% $row->{artist_id} %>'
				><% $row->{artist_name} %></a>
		</td>
	</tr>
% }

	<tr <% (++$n%2) ? 'class="odd"' : '' |n %>>
		<td></td>
		<td><a href="/showtrack.html?trackid=<% $row->{track_id} %>"
				><% $row->{track_name} %></a></td>
		<td class="link">[
%			my $url = "/edittrack.html?album=$row->{album_id}&track=$row->{track_id}";
%			$url .= "&defaultname=" . url_escape($row->{new_name})
%				if defined $row->{new_name};
%			my $word = (defined($row->{new_name}) ? "Suggest" : "Edit");
				<a href="<% $url %>" onclick="
					MyWindow=window.open(
						'<% $url %>&amp;ispopup=1',
						'Edit Track',
						'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=480,height=430'
					);
					return false;
					"><% $word %></a>
			]</td>
	</tr>

%	$lastartist = $row->{artist_id};
%	}

</table>

% }

<& /comp/footer &>
