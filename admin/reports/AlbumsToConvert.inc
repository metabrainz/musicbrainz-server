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
	# This report lists Releases with duplicate TRMs for different tracks.
	#
	# $Id$
	#
</%perl>
<%args>

	$offset => undef
	$page => undef
	$pagesize => undef

	$report_title => "Releases to convert to Multiple Artists"

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

<& /comp/sidebar-notitle, pagetitle => $report_title  &>

	<& /comp/tablebegin, title => $report_title &>
		<ul>
			<li>This report aims to identify releases which need converting to
				"multiple artists". Currently it does this by looking for releases
				where every track contains "/" or "-".</li>
			<li>Total releases found: <% $rep->Records %></li>
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

<%perl>

 	if ($rep->Position < $rep->Records)
	{
		my $lastartist = 0;
		my $n = 0;

		for my $i (0 .. $pagesize-1)
		{
			my $row = $rep->Get or last;

			if ($row->{artist_id} != $lastartist)
			{
				my $ar = Artist->new(undef);
				$ar->SetId($row->{artist_id});
				$ar->SetMBId($row->{artist_mbid});
				$ar->SetName($row->{artist_name});
				$ar->SetSortName($row->{artist_sortname});
				$ar->SetResolution($row->{artist_resolution});
				$ar->SetModPending($row->{artist_modpending});

				$m->comp("/comp/artisttitle", artist => $ar, showlinks => 0, showmodlinks => 0);
			}

</%perl>

		<& /comp/linkrelease, id => $row->{'album_id'}, name => $row->{'album_name'}, strong => 0 &>
		<ul style="margin-top: 2px">

%			for my $track (@{ $row->{tracks} })
%			{

			<li><% $track->{track_seq} %>.&nbsp; <% $track->{track_name} %>

%			}

		</ul>

%			$lastartist = $row->{artist_id};
%		}


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

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
