%# vi: set ts=2 sw=2 ft=mason :
<%args>
$offset => undef
$page => undef
$pagesize => undef
</%args>
<%perl>

use Artist;
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

my $mb = $m->comp('/comp/dblogin');

</%perl>

<& /comp/sidebar, title => 'Possibly duplicate artists' &>

<p>
	This report aims to identify artists with very similar names,
	which might indicate that the artists need to be merged.
</p>

<p>Found <% $rep->Records %> artists.</p>

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

<table width="100%">
	<tr>
		<th>Artist Name</th>
		<th>Artist Sortname</th>
		<th style="text-align: right">Albums</th>
		<th style="text-align: right">Tracks</th>
	</tr>

% for my $i (0 .. $pagesize-1) {
%   my $dupelist = $rep->Get or last;

% foreach my $row ( @$dupelist ) {
% my $ar = Artist->new($mb->{DBH});
% $ar->SetId( $row->{artist_id} );
% $ar->LoadFromId();
	<tr>
		<td <% ($ar->GetModPending) ? 'class="mp"' : '' |n %>>
			<a href="/showartist.html?artistid=<% $row->{artist_id} %>"
				><% $row->{artist_name} %></a>
		</td>
		<td>
			<% $row->{artist_sortname} %>
		</td>
		<td style="text-align: right"><% $row->{num_albums} %></td>
		<td style="text-align: right"><% $row->{num_tracks} %></td>
	</tr>
% }

	<tr><td>&nbsp;</td></tr>

% }

</table>

% }

<p> Generated <% $m->comp('/comp/datetime', $rep->Time) %> </p>

<& /comp/footer &>
