#!/usr/bin/perl -w

use strict;
use QuerySupport;
use DBI;
use DBDefs;
use RDFOutput2;
use Apache;
use RDFStore::Parser::SiRPAC;
use RDFStore::NodeFactory;

my ($i, $line, $r, $rdf, $out);
my ($queryname, $querydata, $data, $rdfinput);
my ($function, @queryargs, $mb, $parser, @triples);
my ($currentURI, $rdfquery, $depth);

my %Queries = 
(
   GetCDInfo => 
      [ \&QuerySupport::GetCDInfoMM2, 
        'http://musicbrainz.org/mm/mm-2.0#cdindexId',
        'http://musicbrainz.org/mm/mm-2.0#lastTrack'],
   AssociateCDFromAlbumId =>
      [ \&QuerySupport::AssociateCDMM2, 
        'http://musicbrainz.org/mm/mm-2.0#cdindexId',
        'http://musicbrainz.org/mm/mq-1.0#albumId'],
   FindArtist =>
      [\&QuerySupport::FindArtistByName, 
        'http://musicbrainz.org/mm/mq-1.0#artistName'],
   FindAlbum =>
      [\&QuerySupport::FindAlbumByName, 
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mq-1.0#artistName'],
   FindAlbumsByArtistName =>
      [\&QuerySupport::FindAlbumsByArtistName, 
        'http://musicbrainz.org/mm/mq-1.0#artistName'],
   FindTrack => 
      [\&QuerySupport::FindTrackByName, 
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mq-1.0#artistName'],
   FindDistinctTRMID => 
      [\&QuerySupport::FindDistinctGUID, 
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mq-1.0#artistName'],
   ExchangeMetadata =>
      [\&QuerySupport::ExchangeMetadata, 
        'http://musicbrainz.org/mm/mq-1.0#artistName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mm-2.0#trackNum',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mm-2.0#fileName',
        'http://musicbrainz.org/mm/mm-2.0#issued',
        'http://musicbrainz.org/mm/mm-2.0#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.0#duration',
        'http://musicbrainz.org/mm/mm-2.0#bitprint',
        'http://musicbrainz.org/mm/mm-2.0#first20',
        'http://musicbrainz.org/mm/mm-2.0#fileSize',
        'http://musicbrainz.org/mm/mm-2.0#audioSha1',
        'http://musicbrainz.org/mm/mm-2.0#sampleRate',
        'http://musicbrainz.org/mm/mm-2.0#bitRate',
        'http://musicbrainz.org/mm/mm-2.0#channels',
        'http://musicbrainz.org/mm/mm-2.0#vbr'],
   ExchangeMetadataLite =>
      [\&QuerySupport::ExchangeMetadata, 
        'http://musicbrainz.org/mm/mq-1.0#artistName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mm-2.0#trackNum',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mm-2.0#fileName',
        'http://musicbrainz.org/mm/mm-2.0#issued',
        'http://musicbrainz.org/mm/mm-2.0#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.0#duration',
        'http://musicbrainz.org/mm/mm-2.0#sha1'],
   SubmitAndLookupMetadata =>
      [\&QuerySupport::ExchangeMetadata, 
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mq-1.0#artistName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mm-2.0#trackNum',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mm-2.0#fileName',
        'http://musicbrainz.org/mm/mm-2.0#issued',
        'http://musicbrainz.org/mm/mm-2.0#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.0#duration',
        'http://musicbrainz.org/mm/mm-2.0#bitprint',
        'http://musicbrainz.org/mm/mm-2.0#first20',
        'http://musicbrainz.org/mm/mm-2.0#fileSize',
        'http://musicbrainz.org/mm/mm-2.0#audioSha1',
        'http://musicbrainz.org/mm/mm-2.0#sampleRate',
        'http://musicbrainz.org/mm/mm-2.0#bitRate',
        'http://musicbrainz.org/mm/mm-2.0#channels',
        'http://musicbrainz.org/mm/mm-2.0#vbr'],
   SubmitAndLookupMetadataLite =>
      [\&QuerySupport::ExchangeMetadata, 
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mq-1.0#artistName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mm-2.0#trackNum',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mm-2.0#fileName',
        'http://musicbrainz.org/mm/mm-2.0#issued',
        'http://musicbrainz.org/mm/mm-2.0#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.0#duration',
        'http://musicbrainz.org/mm/mm-2.0#sha1'],
   LookupMetadata =>
      [\&QuerySupport::LookupMetadata, 
        'http://musicbrainz.org/mm/mm-2.0#trmid'],
   SubmitTrack =>
      [\&QuerySupport::SubmitTrack, 
        'http://musicbrainz.org/mm/mq-1.0#artistName',
        'http://musicbrainz.org/mm/mq-1.0#albumName',
        'http://musicbrainz.org/mm/mq-1.0#trackName',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mm-2.0#trackNum',
        'http://musicbrainz.org/mm/mm-2.0#duration',
        'http://musicbrainz.org/mm/mm-2.0#issued',
        'http://musicbrainz.org/mm/mm-2.0#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.0#link'],
   SubmitTrackTRMId =>
      [\&QuerySupport::SubmitTrackTRMId, 
        'http://musicbrainz.org/mm/mm-2.0#trackid',
        'http://musicbrainz.org/mm/mm-2.0#trmid',
        'http://musicbrainz.org/mm/mq-1.0#sessionId',
        'http://musicbrainz.org/mm/mq-1.0#sessionKey'],
   AuthenticateQuery =>
      [\&QuerySupport::AuthenticateQuery, 
        'http://musicbrainz.org/mm/mq-1.0#username']
);  

sub Statement
{
   my ($expat, $st) = @_;
   my ($t);

   if ($st->predicate->getLabel =~ m/_(\d+)$/)
   {
      $st->{ordinal} = $1;
   }
   $t = $expat->{__mbtriples};
   push @$t, $st;
}

sub Output
{
   my ($r, $out) = @_;

   #print STDERR "Query return:\n$$out\n";
   #print STDERR length($$out), " bytes.\n\n";

   if (defined $r)
   {
      $r->status(200);
      $r->content_type("text/plain");
      $r->header_out('Content-Length', length($$out));
      $r->send_http_header();

      if (! $r->header_only)
      {
         print($$out);
      }
      return 200;
   }
   else
   {
      my $header = new HTTP::Headers(
           Connection => "close",
           Content_Type => "text/xml",
           Content_Length => length($$out));
      print $header->as_string(), "\n";
      print $$out;
   }
}

if (exists $ENV{"MOD_PERL"})
{
   $r = Apache->request();
   my $size = $r->header_in("Content-length");
   $r->read($rdfinput, $size);
}
else
{
   while(defined($line = <>))
   {
      $rdfinput .= $line;
   }
}

$rdf = RDFOutput2->new(0);
$rdf->SetBaseURI("http://" . $ENV{SERVER_NAME});
if (!defined $rdf)
{
    $out = $rdf->ErrorRDF("An RDF object must be supplied.");
    Output($r, \$out);
    exit(0);
}

$parser=new RDFStore::Parser::SiRPAC( 
                NodeFactory => new RDFStore::NodeFactory(),
                Handlers => { Assert  => \&Statement });
$parser->{__mbtriples} = \@triples;
eval
{
    #print STDERR "$rdfinput\n";
    $parser->parse($rdfinput);
};
if ($@)
{
    $@ =~ tr/\n\r/  /;
    $@ =~ s/at \/.*$//;
    $out = $rdf->ErrorRDF("Cannot parse query: $@");
    Output($r, \$out);
    exit(0);
}


# Find the toplevel URI
$currentURI = $triples[0]->subject->getLabel;

# Check to see if the client specified a depth for this query. If not,
# use a depth of 2 by default.
$depth = QuerySupport::Extract(\@triples, $currentURI, -1, 
                 "http://musicbrainz.org/mm/mq-1.0#depth");
if (not defined $depth)
{
   $depth = 2;
}
$rdf->SetDepth($depth);


# Extract the name of the qyery
$queryname = QuerySupport::Extract(\@triples, $currentURI, -1, 
                 "http://www.w3.org/1999/02/22-rdf-syntax-ns#type");
if (!defined $queryname)
{
    $out = $rdf->ErrorRDF("Cannot determine query name.");
    Output($r, \$out);
    exit(0);
}

$queryname =~ s/^.*#//;
#print STDERR "query: '$queryname'\n";
 
if (!exists $Queries{$queryname})
{
    $out = $rdf->ErrorRDF("Query '$queryname' is not supported.");
    print STDERR "$out\n\n";
    Output($r, \$out);
    exit(0);
}
$querydata = $Queries{$queryname};

$function = shift @$querydata;
for(;;)
{
    $rdfquery = shift @$querydata;
    last if (!defined $rdfquery);

    #print STDERR "$rdfquery: ";
    $data = QuerySupport::Extract(\@triples, $currentURI, -1, $rdfquery);
    $data = undef if (defined $data && $data eq '');
    $data = "" if (defined $data && $data eq "__NULL__");
    #print STDERR "query args: '$data'\n" if defined $data;
    push @queryargs, $data;
    $rdfquery = undef;
}

$mb = new MusicBrainz(1);
if (!$mb->Login(1))
{
    $out = $rdf->ErrorRDF("Database Error: ".$DBI::errstr.")");
    Output($r, \$out);
    exit(0);
}

$rdf->SetDBH($mb->{DBH});
$out = $function->($mb->{DBH}, \@triples, $rdf, @queryargs);
$mb->Logout;


if (!defined $out)
{
    $out = $rdf->ErrorRDF("Query failed.");
}


Output($r, \$out);
