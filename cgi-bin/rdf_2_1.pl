#!/usr/bin/perl -w

no warnings qw( portable );
use strict;
use QuerySupport;
use DBI;
use DBDefs;
use Apache;
use Apache::Request;
use MM_2_1;

my ($rdf, $mb, $query, $id, $out, $r, $depth);
my %Queries =
(
   artist => \&QuerySupport::GetArtistByGlobalId,
   album => \&QuerySupport::GetAlbumByGlobalId,
   track => \&QuerySupport::GetTrackByGlobalId,
   trmid => \&QuerySupport::GetTrackByTRM,
   trm => \&QuerySupport::GetTrackByTRM
);

$depth = 2;
$rdf = MM_2_1->new(0);

$rdf->SetBaseURI("http://" . $ENV{SERVER_NAME});

if (exists $ENV{"MOD_PERL"})
{
   my $apr;

   $r = Apache->request();
   $apr = Apache::Request->new($r);
   $id = $apr->param('id');
   $query = $apr->param('query');
   $depth = $apr->param('depth') if (defined $apr->param('depth'));
}
else
{
   if ($ENV{SCRIPT_URI} =~ /.*\/(.*)\/(.*)$/)
   {
      $query = $1;
      $id = $2;
      $depth = $3 if (defined $3);
   }
}

$rdf->SetDepth($depth);

#print STDERR "$query $id\n";

if ($depth > 6)
{
    $out = $rdf->ErrorRDF("Query depth cannot be larger than 6!");
}
elsif (!defined $query || $query eq '' || !defined $id || $id eq '')
{
    $out = $rdf->ErrorRDF("The id and query arguments must be given.");
}
else
{
    $mb = new MusicBrainz(1);
    if (!$mb->Login(1))
    {
        $out = print $rdf->ErrorRDF("Database Error: ".$DBI::errstr.")");
    }
    else
    {
        $rdf->SetDBH($mb->{DBH});
        if (! exists $Queries{$query})
        {
            $out = $rdf->ErrorRDF("The query type $query not supported.");
        }
        else
        {
            $out = $Queries{$query}($mb->{DBH}, undef, $rdf, $id);
        }
        $mb->Logout;
    }
}

if (defined $r)
{
   $r->status(200);
   $r->content_type("text/xml");
   $r->header_out('Content-Length', length($out));
   $r->send_http_header();
   if (! $r->header_only)
   {
      print($out);
   }
   return 200;
}
else
{
   my $header = new HTTP::Headers(
        Connection => "close",
        Content_Type => "text/xml",
        Content_Length => length($out));
   print $header->as_string(), "\n";
   print $out;
}
