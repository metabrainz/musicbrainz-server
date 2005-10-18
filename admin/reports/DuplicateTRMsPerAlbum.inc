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
    <th>TRM</th>
    <th>Track</th>
    <th>Track Name</th>
    <th>Length</th>
  </tr>

% my $n = 0;
% for my $i (0 .. $pagesize-1) {
%   my $row = $rep->Get or last;
  <tr>
    <td colspan="4" class="head">
      <a href="/showtrm.html?trm=<% $row->{'trm'} %>"><% $row->{'trm'} %></a><br>
      &nbsp;[artist: <a href="/showartist.html?artistid=<% $row->{'artist_id'} %>"><% $row->{'artist_name'} %></a> - album:
      <a href="/showalbum.html?albumid=<% $row->{'album_id'} %>"><% $row->{'album_name'} %></a>]
    </td>
  </tr>

% $n = 1;
%   for my $track (@{ $row->{'tracks'} }) {
  <tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
    <td></td>
    <td><% $track->{sequence} %></td>
    <td><a href="/showtrack.html?trackid=<% $track->{track_id} %>"><% $track->{track_name} %></a></td>
    <td><% Track::FormatTrackLength($track->{'length'}) %></td>
   </tr>
%   } 
  <tr><td>&nbsp;</td></tr>
% }

</table>

% }

<& /comp/footer &>
