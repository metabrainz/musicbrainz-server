%# vi: set ts=2 sw=2 ft=mason :
<%args>
$reportdir => undef
$offset => undef
$page => undef
$pagesize => undef
</%args>
<%perl>

use Album;
use Artist;
use MusicBrainz::Server::PagedReport;
use File::Basename qw( dirname );
use ModDefs;

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
		<th>Album Name</th>
		<th style="text-align: right">Tracks</th>
		<th>&nbsp;</th>
	</tr>

%	for my $i (0 .. $pagesize-1) {
%		my $dupelist = $rep->Get or last;
%		my @section;
%
%		# read album and artist information if the album exists
%		foreach my $entry ( @$dupelist ) {
%			my $al = Album->new($mb->{DBH});
%			$al->SetMBId( $entry->{album_mbid} );
%			if ( $al->LoadFromId(1) ) {
%				my $ar = Artist->new($mb->{DBH});
%				$ar->SetId($al->GetArtist);
%				$ar->LoadFromId;
%				push @section, { album_obj => $al, artist_obj => $ar,
%								mac => ( $al->GetArtist == &ModDefs::VARTIST_ID ) ? 1 : 0};
%			}
%		}
%
%		# this causes the section to be skipped if we don't have enough albums
%		@section = ( ) if @section == 1;
%
%		# Add information needed for the 'Merge into this' links.
%		foreach my $entry ( @section ) {
%			foreach my $other ( @section ) {
%				push @{$entry->{others}}, $other->{album_obj}->GetId
%					if $entry->{album_obj}->GetId != $other->{album_obj}->GetId;
%			}
%		}
%
%		# All data has been gathered. Write the section.
%		foreach my $entry ( @section ) {
%			my $al = $entry->{album_obj};
%			my $ar = $entry->{artist_obj};
	<tr>
				<td <% ($ar->GetModPending) ? 'class="mp"' : '' |n %>>
						<a href="/artist/<% $ar->GetMBId %>.html"
							><% $ar->GetName %></a></td>
				<td <% ($al->GetModPending) ? 'class="mp"' : '' |n %>>
						<a href="/album/<% $al->GetMBId %>.html"
							><% $al->GetName %></a></td>
				<td style="text-align: right"><% $al->GetTrackCount %></td>
				<td><a href="/edit/albumbatch/merge.html?album=<% $al->GetId %>&amp;album=<%
							join('&album=', @{ $entry->{others} }) %>&amp;mac=<% $entry->{mac} %>"
				>Merge into this</a></td>
	</tr>
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
