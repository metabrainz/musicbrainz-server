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
	# Render a list of releases with links to the merge releases page.
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

	use Album;
	use Artist;
	use MusicBrainz::Server::PagedReport;
	use File::Basename qw(dirname);
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
			<th>Release Name</th>
			<th style="text-align: right">Tracks</th>
			<th>&nbsp;</th>
		</tr>

<%perl>

		for my $i (0 .. $pagesize-1)
		{
			my $dupelist = $rep->Get or last;
			my @section;

			# read album and artist information if the album exists
			foreach my $entry (@$dupelist)
			{
				my $al = Album->new($mb->{DBH});
				$al->SetMBId($entry->{album_mbid});
				if ($al->LoadFromId(1))
				{
					my $ar = Artist->new($mb->{DBH});
					$ar->SetId($al->GetArtist);
					$ar->LoadFromId;
					push @section, {
						album_obj => $al,
						artist_obj => $ar,
						mac => ($al->GetArtist == &ModDefs::VARTIST_ID) ? 1 : 0
					};
				}
			}

			# this causes the section to be skipped if we don't have enough releases
			@section = () if @section == 1;

			# Add information needed for the 'Merge into this' links.
			foreach my $entry (@section)
			{
				foreach my $other (@section)
				{
					push @{$entry->{others}}, $other->{album_obj}->GetId
						if $entry->{album_obj}->GetId != $other->{album_obj}->GetId;
				}
			}

			# All data has been gathered. Write the section.
			foreach my $entry (@section)
			{
				my $al = $entry->{album_obj};
				my $ar = $entry->{artist_obj};

</%perl>

		<tr>
			<td <% ($ar->GetModPending) ? 'class="mp"' : '' |n %>>
				<& /comp/linkartist, artist => $artist &>

			<td <% ($al->GetModPending) ? 'class="mp"' : '' |n %>>
				<& /comp/linkrelease, release => $al &>

			<td style="text-align: right">
				<% $al->GetTrackCount %></td>
			<td>
				<a href="/edit/albumbatch/merge.html?album=<% $al->GetId %>&amp;album=<% join('&album=', @{ $entry->{others} }) %>&amp;mac=<% $entry->{mac} %>">Merge into this</a></td>
		</tr>

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

%	}

%# vi: set ts=4 sw=4 ft=mason :
