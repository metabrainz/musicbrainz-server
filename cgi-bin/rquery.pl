#!/usr/bin/perl -w

use strict;
use XML::XQL::DOM;
use QuerySupport;
use XMLParse;
use DBI;
use DBDefs;
use Apache;

my ($i, $line, $xml, $supp_xml, $r);
my ($parser, $doc, $queryname, $querydata, $data);
my ($function, $xqlquery, @queryargs, $cd);

my %Queries = 
(
   GetCDInfoFromCDIndexId => 
      [ \&QuerySupport::GenerateCDInfoObjectFromDiskId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id',
        '/rdf:RDF/rdf:Description/MQ:Args/@last', 
        '/rdf:RDF/rdf:Description/MQ:Args/@toc'],
   AssociateCDFromAlbumId =>
      [ \&QuerySupport::AssociateCDFromAlbumId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id',
        '/rdf:RDF/rdf:Description/MQ:Args/@toc', 
        '/rdf:RDF/rdf:Description/MQ:Args/@associate'],
   FindArtistByName =>
      [\&QuerySupport::FindArtistByName, 
        '/rdf:RDF/rdf:Description/MQ:Args/@artist'],
   FindAlbumByName =>
      [\&QuerySupport::FindAlbumByName, 
        '/rdf:RDF/rdf:Description/MQ:Args/@album', 
        '/rdf:RDF/rdf:Description/MQ:Args/@artist'],
   FindAlbumsByArtistName =>
      [\&QuerySupport::FindAlbumsByArtistName, 
        '/rdf:RDF/rdf:Description/MQ:Args/@artist'],
   FindTrackByName => 
      [\&QuerySupport::FindTrackByName, 
        '/rdf:RDF/rdf:Description/MQ:Args/@track', 
        '/rdf:RDF/rdf:Description/MQ:Args/@album', 
        '/rdf:RDF/rdf:Description/MQ:Args/@artist'],
   FindDistinctGUID => 
      [\&QuerySupport::FindDistinctGUID, 
        '/rdf:RDF/rdf:Description/MQ:Args/@track', 
        '/rdf:RDF/rdf:Description/MQ:Args/@artist'],
   GetArtistById =>
      [\&QuerySupport::GetArtistByGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   GetAlbumById =>
      [\&QuerySupport::GetAlbumByGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   GetTrackById =>
      [\&QuerySupport::GetTrackByGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   GetAlbumsByArtistId =>
      [\&QuerySupport::GetAlbumsByArtistGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   ExchangeMetadata =>
      [\&QuerySupport::ExchangeMetadata, 
        '/rdf:RDF/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/DC:Identifier/@guid',
        '/rdf:RDF/rdf:Description/DC:Creator',
        '/rdf:RDF/rdf:Description/MM:Album',
        '/rdf:RDF/rdf:Description/DC:Relation/@track',
        '/rdf:RDF/rdf:Description/DC:Format/@duration',
        '/rdf:RDF/rdf:Description/DC:Date/@issued',
        '/rdf:RDF/rdf:Description/MM:Genre',
        '/rdf:RDF/rdf:Description/DC:Identifier/@fileName',
        '/rdf:RDF/rdf:Description/DC:Description'],
   SubmitTrack =>
      [\&QuerySupport::SubmitTrack, 
        '/rdf:RDF/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/DC:Identifier/@guid',
        '/rdf:RDF/rdf:Description/DC:Creator',
        '/rdf:RDF/rdf:Description/MM:Album',
        '/rdf:RDF/rdf:Description/DC:Relation/@track',
        '/rdf:RDF/rdf:Description/DC:Format/@duration',
        '/rdf:RDF/rdf:Description/DC:Date/@issued',
        '/rdf:RDF/rdf:Description/MM:Genre',
        '/rdf:RDF/rdf:Description/DC:Description',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/@about',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/DC:Contributor',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/DC:Type/@type',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/DC:Date'],
   GetLyricsById =>
      [\&QuerySupport::GetLyricsByGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id']
);  

if (exists $ENV{"MOD_PERL"})
{
   $r = Apache->request();
   my $size = $r->header_in("Content-length");
   $r->read($xml, $size);
}
else
{
   for($i = 0; defined($line = <>); $i++)
   {
       if ($i > 0 && $line =~ /^<\?xml/)
       {
          $supp_xml = $line;
          while(defined($line = <>))
          {
              $supp_xml .= $line;
          }
          last;
       }
       $xml .= $line;
   }
}
if (!defined $xml)
{
    print QuerySupport::EmitErrorRDF("An RDF object must be supplied.");
    exit(0);
}

$parser = new XML::DOM::Parser;
eval
{
    $doc = $parser->parse($xml);
};
if ($@)
{
    $@ =~ tr/\n\r/  /;
    print QuerySupport::EmitErrorRDF("Cannot parse query: $@");
    print STDERR QuerySupport::EmitErrorRDF("Cannot parse query: $@");
    print STDERR "$xml\n";
    exit(0);
}

$queryname = QuerySupport::SolveXQL($doc, "/rdf:RDF/rdf:Description/MQ:Query");
if (!defined $queryname)
{
    print QuerySupport::EmitErrorRDF("Cannot determine query name.");
    exit(0);
}
if (!exists $Queries{$queryname})
{
    print QuerySupport::EmitErrorRDF("Cannot find query $queryname.");
    exit(0);
}
$querydata = $Queries{$queryname};

$function = shift @$querydata;
for(;;)
{
    $xqlquery = shift @$querydata;
    last if (!defined $xqlquery);

    if ($xqlquery ne '')
    {
        $data = QuerySupport::SolveXQL($doc, $xqlquery);
        $data = undef if (defined $data && $data eq '');
    }
    else
    {
        $data = $supp_xml;
    }
    push @queryargs, $data;
    $xqlquery = undef;
}

$cd = new MusicBrainz(1);
if (!$cd->Login(1))
{
    print QuerySupport::EmitErrorRDF("Database Error: ".$DBI::errstr.")");
    exit(0);
}

$xml = $function->($cd, $doc, @queryargs);
$cd->Logout;

if (!defined $xml)
{
    print QuerySupport::EmitErrorRDF("Query failed.");
    exit(0);
}

if (defined $r)
{
   $r->status(200);
   $r->content_type("text/plain");
   $r->header_out('Content-Length', length($xml));
   $r->send_http_header();
   print($xml);
   return 200;
}
else
{
   print "Content-type: text/plain\n";
   print "Content-Length: " . length($xml) . "\n\r\n";
   print $xml;
}
