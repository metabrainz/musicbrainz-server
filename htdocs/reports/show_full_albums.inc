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

$pagesize = 4
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
%		my $artist = $rep->Get or last;

%		my $ar = Artist->new($mb->{DBH});
%		$ar->SetId($artist->{ID});
%		$ar->LoadFromId();
%
		<& /comp/artisttitle, artist => $ar, link => 1 &>

%		for my $album ( values %{ $artist->{ALBUMS} } ) {
%			my $al = new Album($mb->{DBH});
%			$al->SetId($album->{ID});
%			$al->LoadFromId();

			<& /comp/album, album => $al, artist => $ar,
				showalbumdetail => 1,
				mbtagger => 0,
				showids => 1,
				showtag => 1,
			&>

%		}

% }

% }

<p>Generated <% $m->comp('/comp/datetime', $rep->Time) %></p>
