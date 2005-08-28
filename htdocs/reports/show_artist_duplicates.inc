%# vi: set ts=2 sw=2 ft=mason :
<%args>
$reportdir => undef
$offset => undef
$page => undef
$pagesize => undef
</%args>
<%perl>

use Artist;
use MusicBrainz::Server::PagedReport;
use File::Basename qw( dirname );

$reportdir = dirname($m->caller(1)->source_file) unless defined $reportdir;
my $rep = MusicBrainz::Server::PagedReport->Load("$reportdir/report");

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

<p>Report generated: <% $m->comp('/comp/datetime', $rep->Time) %></p>
<p>Duplicates found: <% $rep->Records %></p>

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

<table id="Report" class="SpacedColumns TopAlignCells" width="100%">
	<tr>
		<th>Artist Name</th>
		<th>Artist Sortname</th>
		<th style="text-align: right">Albums</th>
		<th style="text-align: right">Tracks</th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
	</tr>

%	for my $i (0 .. $pagesize-1) {

<%perl>
		my $dupelist = $rep->Get or last;
		my @artists;
		foreach my $entry ( @$dupelist )
		{
			my $artist = Artist->new($mb->{DBH});
			$artist->SetMBId( $entry->{artist_mbid} );
			my $valid = $artist->LoadFromId;

			push @artists, {
				obj					=> $artist,
				valid				=> $valid,
				num_albums	=> $entry->{num_albums},
				num_tracks	=> $entry->{num_tracks},
			};
		}

		if ( @artists == 2 and $artists[0]->{valid} and $artists[1]->{valid} )
		{
			$artists[0]->{merge_into} = $artists[1]->{obj}->GetId;
			$artists[1]->{merge_into} = $artists[0]->{obj}->GetId;
		}
</%perl>

%	foreach my $ar ( @artists ) {
%			if ( $ar->{valid} ) {
	<tr>
		<td <% ($ar->{obj}->GetModPending) ? 'class="mp"' : '' |n %>>
			<a href="/artist/<% $ar->{obj}->GetMBId %>.html"
				><% $ar->{obj}->GetName %></a>
		</td>
		<td>
			<% $ar->{obj}->GetSortName %>
		</td>
		<td style="text-align: right"><% $ar->{num_albums} %></td>
		<td style="text-align: right"><% $ar->{num_tracks} %></td>
% if ( defined $ar->{merge_into} ) {
		<td><a href="/edit/artist/merge.html?id=<% $ar->{merge_into} %>&amp;selectedartist=<% $ar->{obj}->GetId %>">Merge into this</a></td>
% } else {
		<td></td>
% }
	</tr>
%			} else {
	<tr>
		<td><em>Artist merged or deleted</em></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
%			}
%		}
	<tr><td>&nbsp;</td></tr>
%	}

</table>

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
