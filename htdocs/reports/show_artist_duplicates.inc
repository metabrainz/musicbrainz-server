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
	# Render a list of artists with links to the merge artists page.
	#
	# $Id$
	#
</%perl>
<%args>

	$reportdir => undef
	$offset => undef
	$page => undef
	$pagesize => undef

	$report_title => "Browse results"
	$report_text => ""

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

	<& /comp/tablebegin, title => $report_title &>

		<ul>
			<% $report_text ? "<li>$report_text</li>" : "" |n %>
			<li>Total duplicates found: <% $rep->Records %></li>
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

	<table id="Report" class="SpacedColumns TopAlignCells" width="100%">
		<tr>
			<th>Artist Name</th>
			<th>Artist Sortname</th>
			<th style="text-align: right">Releases</th>
			<th style="text-align: right">Tracks</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>

<%perl>

		for my $i (0 .. $pagesize-1)
		{

			my $dupelist = $rep->Get or last;
			my @artists;
			foreach my $entry ( @$dupelist )
			{
				my $artist = Artist->new($mb->{DBH});
				$artist->SetMBId( $entry->{artist_mbid} );
				my $valid = $artist->LoadFromId;

				push @artists, {
					obj => $artist,
					valid => $valid,
					num_albums => $entry->{num_albums},
					num_tracks => $entry->{num_tracks},
				};
			}

			if ( @artists == 2 and $artists[0]->{valid} and $artists[1]->{valid} )
			{
				$artists[0]->{merge_into} = $artists[1]->{obj}->GetId;
				$artists[1]->{merge_into} = $artists[0]->{obj}->GetId;
			}

			foreach my $ar ( @artists )
			{
				if ( $ar->{valid} )
				{

</%perl>

		<tr>
			<td <% ($ar->{obj}->GetModPending) ? 'class="mp"' : '' |n %>>
				<& /comp/linkartist, artist => $ar->{obj} &>
			</td>
			<td>
				<% $ar->{obj}->GetSortName %>
			</td>
			<td style="text-align: right"><% $ar->{num_albums} %></td>
			<td style="text-align: right"><% $ar->{num_tracks} %></td>

% 					if ( defined $ar->{merge_into} )
%					{

			<td><a href="/edit/artist/merge.html?id=<% $ar->{merge_into} %>&amp;selectedartist=<% $ar->{obj}->GetId %>">Merge into this</a></td>

% 					}
%					else
%					{

			<td></td>

% 					}
		</tr>

%				}
%				else
%				{

		<tr>
			<td><em>Artist merged or deleted</em></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>


%				}
%			}

		<tr><td>&nbsp;</td></tr>

%		}

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
