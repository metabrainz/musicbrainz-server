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

my $mb = $m->comp('/comp/dblogin');
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

<table id="Report" class="SpacedRows SpacedColumns TopAlignCells" width="100%">
	<tr>
		<th>Artist Name</th>
		<th>Track Name</th>
		<th>&nbsp;</th>
	</tr>

%	my $lastartist = 0;
% my $n = 1;
%	for my $i (0 .. $pagesize-1) {
%		my $row = $rep->Get or last;

% if ($row->{artist_id} != $lastartist) {
	<tr>
		<td colspan="3">&nbsp;</td>
	</td>
	<tr>
		<td colspan="3" class="head">
			<a href='/showartist.html?artistid=<% $row->{artist_id} %>'
				><% $row->{artist_name} %></a>
		</td>
	</tr>
% $n = 1;
% }

% my $tr = Track->new($mb->{DBH});
% $tr->SetId($row->{track_id});
% $tr->LoadFromId;
%
	<tr <% (++$n%2) ? 'class="shade"' : '' |n %>>
		<td></td>
		<td <% ($tr->GetModPending) ? 'class="mp"' : '' |n %>>
			<a href="/showtrack.html?trackid=<% $row->{track_id} %>"
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

<p> Generated <% $m->comp('/comp/datetime', $rep->Time) %> </p>
