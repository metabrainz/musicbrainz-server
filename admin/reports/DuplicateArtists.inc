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
	# This report lists possibly duplicate artists.
	#
	# $Id$
	#
</%perl>
<%args>

	$offset => undef
	$page => undef
	$pagesize => undef

	$report_title => "Possibly duplicate artists"

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

<& /comp/sidebar-notitle, pagetitle => $report_title &>

	<& /comp/tablebegin, title => $report_title &>
		<ul>
			<li>This report aims to identify artists with very similar names,
				which might indicate that the artists need to be merged.</li>
			<li>Total artists found: <% $rep->Records %></li>
			<li>Generated <% $m->comp('/comp/datetime', $rep->Time) %></li>
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
			<td class="left padright">Artist Sortname</td>
			<td class="right padright">Releases</td>
			<td class="right padright">Tracks</td>
		</tr>

% 		for my $i (0 .. $pagesize-1)
%		{
%  			my $dupelist = $rep->Get or last;

%			my $j = 0;
% 			foreach my $row ( @$dupelist )
%			{
% 				my $ar = Artist->new($mb->{DBH});
% 				$ar->SetId( $row->{artist_id} );
% 				$ar->LoadFromId();

		<tr class="<% $j++ % 2 == 0 ? "even" : "odd" %>">
			<td class="left padright">
				<span <% ($ar->GetModPending) ? 'class="mp"' : '' |n %>>
				<& /comp/linkartist, artist => $ar, strong => 0 &></td>
				</span>
			<td class="left padright">
				<% $ar->GetSortName %></td>
			<td class="right padright">
				<% $row->{num_albums} %></td>
			<td class="right padright">
				<% $row->{num_tracks} %></td>
		</tr>

% 			}

		<tr><td>&nbsp;</td></tr>

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


<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
