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

<& /comp/sidebar, title => 'Albums to convert to Multiple Artists' &>

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>

<p>
    This report aims to identify albums which need converting to
    "multiple artists".&nbsp;
    Currently it does this by looking for albums where every track
    contains "/" or "-".
</p>

<p>Total albums found: <% $rep->Records %></p>

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

%	my $lastartist = 0;
% my $n = 0;
%	for my $i (0 .. $pagesize-1) {
%		my $row = $rep->Get or last;

% if ($row->{artist_id} != $lastartist) {
%		my $ar = Artist->new(undef);
%		$ar->SetId($row->{artist_id});
%		$ar->SetMBId($row->{artist_mbid});
%		$ar->SetName($row->{artist_name});
%		$ar->SetSortName($row->{artist_sortname});
%		$ar->SetModPending($row->{artist_modpending});
		<& /comp/artisttitle, artist => $ar, link => 0, showmodlinks => 0 &>
% }

		<p><b><a href='/album/<% $row->{'album_mbid'} %>.html'
			><% $row->{'album_name'} %></a></b></p>
		<ul>
%		for my $track (@{ $row->{tracks} }) {
			<li><% $track->{track_seq} %>.&nbsp; <% $track->{track_name} %>
%		}
		</ul>

%	$lastartist = $row->{artist_id};
%	}

<br><br>
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

% }

<& /comp/footer &>
