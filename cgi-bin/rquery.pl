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
my ($function, $xqlquery, @queryargs, $cd, $version);
my $use_old_style = 0;

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
   GetTrackByGUID =>
      [\&QuerySupport::GetTrackByGUID, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   GetAlbumsByArtistId =>
      [\&QuerySupport::GetAlbumsByArtistGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   ExchangeMetadata =>
      [\&QuerySupport::ExchangeMetadata, 
        '/rdf:RDF/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/DC:Identifier/@guid',
        '/rdf:RDF/rdf:Description/DC:Creator',
        '/rdf:RDF/rdf:Description/DC:Relation/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/MM:TrackNum',
        '/rdf:RDF/rdf:Description/DC:Format/@duration',
        '/rdf:RDF/rdf:Description/DC:Date/@issued',
        '/rdf:RDF/rdf:Description/MM:Genre',
        '/rdf:RDF/rdf:Description/MQ:Filename',
        '/rdf:RDF/rdf:Description/DC:Description'],
   SubmitTrack =>
      [\&QuerySupport::SubmitTrack, 
        '/rdf:RDF/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/DC:Identifier/@guid',
        '/rdf:RDF/rdf:Description/DC:Creator',
        '/rdf:RDF/rdf:Description/DC:Relation/rdf:Description/DC:Title',
        '/rdf:RDF/rdf:Description/MM:TrackNum',
        '/rdf:RDF/rdf:Description/DC:Format/@duration',
        '/rdf:RDF/rdf:Description/DC:Date/@issued',
        '/rdf:RDF/rdf:Description/MM:Genre',
        '/rdf:RDF/rdf:Description/DC:Description'],
   SubmitSyncText =>
      [\&QuerySupport::SubmitSyncText, 
        '/rdf:RDF/rdf:Description/DC:Identifier/@id',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/DC:Contributor',
        '/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/DC:Type/@type'],
   GetSyncTextById =>
      [\&QuerySupport::GetSyncTextByTrackGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id'],
   GetLyricsById =>
      [\&QuerySupport::GetLyricsByGlobalId, 
        '/rdf:RDF/rdf:Description/MQ:Args/@id']
);  

if (exists $ENV{"MOD_PERL"})
{
   $r = Apache->request();
   my $size = $r->header_in("Content-length");
   $r->read($xml, $size);
 #print "perl code\n";
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
 #print "manual code\n";
}
if (!defined $xml)
{
    print QuerySupport::EmitErrorRDF("An RDF object must be supplied.", 1);
    exit(0);
}
#print "creating parser for\n" . $xml . "_end_\n";
$parser = new XML::DOM::Parser;
eval
{
    $doc = $parser->parse($xml);
};
if ($@)
{
    $@ =~ tr/\n\r/  /;
    print QuerySupport::EmitErrorRDF("Cannot parse query: $@", 1);
    #print STDERR QuerySupport::EmitErrorRDF("Cannot parse query: $@");
    #print STDERR "$xml\n";
    exit(0);
}

$version = QuerySupport::SolveXQL($doc, "/rdf:RDF/rdf:Description/MQ:Version");
if (!defined $version || $version eq '')
{
    $use_old_style = 1;
    $xml = UpdateQuery($xml);
}

$queryname = QuerySupport::SolveXQL($doc, "/rdf:RDF/rdf:Description/MQ:Query");
if (!defined $queryname)
{
    print QuerySupport::EmitErrorRDF("Cannot determine query name.", 1);
    exit(0);
}
if (!exists $Queries{$queryname})
{
    print QuerySupport::EmitErrorRDF("Cannot find query $queryname.", 1);
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
    print QuerySupport::EmitErrorRDF("Database Error: ".$DBI::errstr.")", 1);
    exit(0);
}

$xml = $function->($cd, $doc, @queryargs);
$cd->Logout;

if (!defined $xml)
{
    print QuerySupport::EmitErrorRDF("Query failed.", 1);
    exit(0);
}

# Convert the response back if we converted the query
$xml = RevertResponse($xml) if ($use_old_style);

#print STDERR "$xml\n";
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

# This function will take an old style query and convert it to a new
# style query
sub UpdateQuery
{
   my ($xml) = @_;

   $xml =~ s/DC:Relation track=\"(\d+)\"\/>/MM:TrackNum>$1<\/MM:TrackNum>/gs;
   $xml =~ s/MC:Collection/MM:Collection/gs;
   $xml =~ s/<MM:Album>(.*)<\/MM:Album>/<DC:Relation>\n  <rdf:Description>\n    <DC:Title>$1<\/DC:Title>\n  <\/rdf:Description>\n<\/DC:Relation>/gs;
   $xml =~ s/<DC:Identifier\s+guid=\"(.*)\"\s+fileName=\"(.*?)\"\/>/<DC:Identifier guid=\"$1\"\/>\n<MQ:Filename>$2<\/MQ:Filename>/gs;

   return $xml;
}

# This function will take a new style response and convert it to a old
# style response
sub RevertResponse
{
   my ($xml) = @_;

   if ($xml =~ /MM:Collection numParts=\"(\d+)\" type=\"album\">/)
   {
       my $numTracks = $1;

       $xml =~ s/Collection numParts=\"(\d+)\" type=\"album\">(\s+)/Collection type=\"album\">\n      <rdf:Bag>\n      <rdf:li>$2/gs;
       $xml =~ s/DC:Title>(.*?)<\/DC:Title/MM:Album numTracks=\"$numTracks\">$1<\/MM:Album/s;
       $xml =~ s/\/MM:Collection/\/rdf:li>\n    <\/rdf:Bag>\n    <\/MM:Collection/s;

   }

   $xml =~ s/MM:TrackNum>(\d+)<\/MM:TrackNum/DC:Relation track=\"$1\"\//gs;
   $xml =~ s/MM:Collection/MC:Collection/gs;
   $xml =~ s/<DC:Relation>\s+<rdf:Description>\s+<DC:Title>(.*)<\/DC:Title>\s+<\/rdf:Description>\s+<\/DC:Relation>/<MM:Album>$1<\/MM:Album>/gs;
   $xml =~ s/<MQ:Filename>(.*)<\/MQ:Filename>/<DC:Identifier fileName=\"$1\"\/>/gs;

   return $xml;
}
