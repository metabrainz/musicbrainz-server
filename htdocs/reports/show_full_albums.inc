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
	# Render a list with artistitle, and full releases shown.
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

	use MusicBrainz::Server::PagedReport;
	use File::Basename qw( dirname );

	$reportdir = dirname($m->caller(1)->source_file) unless defined $reportdir;
	my $rep = MusicBrainz::Server::PagedReport->Load("$reportdir/report");

	$pagesize = 4
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

	my $mb = $m->comp('/comp/dblogin');

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

<%perl>

 	if ($rep->Position < $rep->Records)
	{
		my $lastartist = 0;
 		my $n = 0;

		for my $i (0 .. $pagesize-1)
		{
			my $artist = $rep->Get or last;

			my $ar = Artist->new($mb->{DBH});
			$ar->SetId($artist->{ID});
			$ar->LoadFromId();

			$m->comp("/comp/artisttitle", artist => $ar, showlinks => 1);

			for my $album ( values %{ $artist->{ALBUMS} } )
			{
				my $al = new Album($mb->{DBH});
				$al->SetId($album->{ID});
				$al->LoadFromId();

				$m->comp("/comp/album",
					album => $al, artist => $ar,
					mbtagger => 0,
					showids => 1,
					showtag => 1
				);
			}

			$m->out("<br />");
			$m->out("<br />");
		}

</%perl>

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
