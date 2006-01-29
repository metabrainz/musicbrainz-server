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

<& /comp/sidebar, title => 'Albums with duplicate TRMs for different tracks',
  head => '
<style type="text/css">
  td.trm { text-align: right; }
</style>
' &>

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<p>
  This report lists TRMs that match for more than one track of an album.
</p>

<p>Total TRMs found: <% $rep->Records %></p>

% if ($rep->Records) {
<& /comp/framedboxbegin, width=>"100%" &>
<& /comp/pageselector,
  numitems  => $rep->Records, 
  numlinks  => 6,
  snaptoend => 2,
  pagesize  => $pagesize,
  offset    => $offset,
  url       => $r->uri,
  args      => { pagesize => $pagesize },
&>
<& /comp/framedboxend &>
<br><br>
% }

% if ($rep->Position < $rep->Records) {

<table id="Report" class="SpacedRows SpacedColumns TopAlignCells">
	<tr>
		<th colspan="2">Artist</th>
		<th>Album</th>
		<th/>
	</tr>
  <tr>
	  <th>&nbsp;</th>
    <th colspan="2">TRM</th>
    <th width="5%">Count</th>
  </tr>

% my $n = 0;
% for my $i (0 .. $pagesize-1) {
%   my $row = $rep->Get or last;
  <tr>
    <td colspan="2" class="head" width="45%">
			<a href="/showartist.html?artistid=<% $row->{'artist_id'} %>"><% $row->{'artist_name'} %></a>
		</td>
		<td colspan="2" class="head">
			<a href="/showalbum.html?albumid=<% $row->{'album_id'} %>"><% $row->{'album_name'} %></a>
		</td>
	</tr>

% $n = 1;
%   for my $trm (@{ $row->{'trms'} }) {
  <tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
    <td width="5%"></td>
    <td colspan="2" align="center"><a href="/showtrm.html?trm=<% $trm->{'trm'} %>"><% $trm->{'trm'} %></a></td>
    <td align="center"><% $trm->{'freq'} %></td>
   </tr>
%   } 
  <tr><td colspan="4">&nbsp;</td></tr>
% }

</table>

% }

<& /comp/footer &>
