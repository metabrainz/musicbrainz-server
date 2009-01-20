<%perl>
	# -----------------------------------------------------------------------------
	#                               Musicbrainz.org
	#                        Copyright (c) 2001 Robert Kaye
	# -----------------------------------------------------------------------------
	#  This software is provided "as is", without warranty of any kind, express or
	#  implied, including  but not limited  to the warranties of  merchantability,
	#  fitness for a particular purpose and noninfringement. In no event shall the
	#  authors or  copyright  holders be  liable for any claim,  damages or  other
	#  liability, whether  in an  action of  contract, tort  or otherwise, arising
	#  from,  out of  or in  connection with  the software or  the  use  or  other
	#  dealings in the software.
	#
	#  GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
	#  Permits anyone the right to use and modify the software without limitations
	#  as long as proper  credits are given  and the original  and modified source
	#  code are included. Requires  that the final product, software derivate from
	#  the original  source or any  software  utilizing a GPL  component, such  as
	#  this, is also licensed under the GPL license.
	# -----------------------------------------------------------------------------
	#
	# Summary:
	# -----------------------------------------------------------------------------
	# Render a list of releases with their release artists.
	#
	# $Id$
	#
</%perl>
<%args>

	$reportdir => undef
	$offset => undef
	$page => undef
	$pagesize => undef
	$show_freedb => undef

	$report_title => "Browse results"
	$report_text => ""

</%args>
<%perl>

	use MusicBrainz::Server::PagedReport;
	use File::Basename qw( dirname );

	$reportdir = dirname($m->caller(1)->source_file) unless defined $reportdir;
	my $rep = MusicBrainz::Server::PagedReport->Load("$reportdir/report");

	$pagesize = 25
		unless MusicBrainz::Server::Validation::IsNonNegInteger($pagesize)
		and $pagesize > 0 and $pagesize <= 100000;

	$offset = ($page-1) * $pagesize
		if not defined $offset
		and MusicBrainz::Server::Validation::IsNonNegInteger($page)
		and $page;

	$offset = 0
		unless MusicBrainz::Server::Validation::IsNonNegInteger($offset)
		and $offset < $rep->Records;

	$rep->Seek($offset);

</%perl>

	<& /comp/tablebegin, title => $report_title &>

		<ul>
			<% $report_text ? "<li>$report_text</li>" : "" |n %>
			<li>Total releases found: <% $rep->Records %></li>
			<li>Report generated: <% $m->comp('/comp/datetime', $rep->Time) %></li>
		</ul>

% 	if ($rep->Records)
%	{

		<& /comp/browse/pageselector,
			numitems => $rep->Records,
			numlinks => 6,
			snaptoend => 2,
			pagesize => $pagesize,
			offset => $offset,
			url => $r->uri,
			args => { pagesize => $pagesize },
		&>

% 	}

	<& /comp/tableend &>


% 	if ($rep->Position < $rep->Records)
%	{

	<table class="listing">
		<tr class="header">
			<td class="left padright">Artist Name</td>
			<td class="left padright">Release Name</td>
%			if ($show_freedb)
%			{
			<td class="left padright">Tracks</td>
			<td class="left padright">FreeDB Search Link</td>
%			}				
		</tr>

%		for my $i (0 .. $pagesize-1)
%		{
%			my $row = $rep->Get or last;

		<tr class="<% ($i % 2) ? "even" : "odd" %>">
			<td class="left padright">
				<& /comp/linkartist,
					id => $row->{'artist_id'},
					name => $row->{'artist_name'},
					sortname => $row->{'artist_sortname'},
					resolution => $row->{'artist_resolution'},
					modpending => $row->{'artist_modpending'},
					strong => 0
				&></td>
			<td class="left padright">
				<& /comp/linkrelease, 
					id => $row->{album_id}, 
					name => $row->{album_name},
					modpending => $row->{'album_modpending'},
					strong => 0 &></td>
%			if ($show_freedb)
%			{
			<td><% $row->{album_tracks} |n %></td>
			<td class="left padright">
%				my $artist = MusicBrainz::Server::LuceneSearch::EscapeQuery($row->{'artist_name'});
%				my $release = MusicBrainz::Server::LuceneSearch::EscapeQuery($row->{'album_name'});
%				my $query =	"artist:(".$artist.") release:(".$release.") " . ($row->{album_tracks} ? "tracks:".$row->{album_tracks} : "");	
				<a href="/search/textsearch.html?type=freedb&query=<% uri_escape($query) %>&adv=on&handlearguments=1">Search in FreeDb</a>
			</td>
%			}				
		</tr>

% 		}

	</table>

	<br />
	<br />

	<& /comp/tablebegin, title => $report_title &>

		<& /comp/browse/pageselector,
			numitems => $rep->Records,
			numlinks => 6,
			snaptoend => 2,
			pagesize => $pagesize,
			offset => $offset,
			url => $r->uri,
			args => { pagesize => $pagesize },
		&>

	<& /comp/tableend &>

% 	}

%# vi: set ts=4 sw=4 ft=mason :
