#!/usr/bin/perl -w

no warnings qw( portable );
use strict;
use QuerySupport;
use TaggerSupport;
use Parser;
use DBI;
use DBDefs;
use MM_2_1;
use Apache;

my ($i, $line, $r, $rdf, $out);
my ($queryname, $querydata, $data, $rdfinput);
my ($function, @queryargs, $mb, $parser);
my ($currentURI, $rdfquery, $depth);
my (%session, $session_id, $session_key, $mustauth);

my %Queries = 
(
   GetCDInfo => 
      [ \&QuerySupport::GetCDInfoMM2, 0, 
        'http://musicbrainz.org/mm/mm-2.1#cdindexid',
        'http://musicbrainz.org/mm/mm-2.1#lastTrack'],
   AssociateCDFromAlbumId =>
      [ \&QuerySupport::AssociateCDMM2, 0, 
        'http://musicbrainz.org/mm/mm-2.1#cdindexid',
        'http://musicbrainz.org/mm/mq-1.1#albumId'],
   FindArtist =>
      [\&QuerySupport::FindArtistByName, 0, 
        'http://musicbrainz.org/mm/mq-1.1#artistName',
        'http://musicbrainz.org/mm/mq-1.1#maxItems'],
   FindAlbum =>
      [\&QuerySupport::FindAlbumByName, 0, 
        'http://musicbrainz.org/mm/mq-1.1#albumName',
        'http://musicbrainz.org/mm/mq-1.1#maxItems'],
   FindTrack => 
      [\&QuerySupport::FindTrackByName, 0, 
        'http://musicbrainz.org/mm/mq-1.1#trackName',
        'http://musicbrainz.org/mm/mq-1.1#maxItems'],
   FindDistinctTRMID => 
      [\&QuerySupport::FindDistinctTRM, 0, 
        'http://musicbrainz.org/mm/mq-1.1#trackName',
        'http://musicbrainz.org/mm/mq-1.1#artistName'],
   LookupMetadata =>
      [\&QuerySupport::LookupMetadata, 0, 
        'http://musicbrainz.org/mm/mm-2.1#trmid'],
   SubmitTrack =>
      [\&QuerySupport::SubmitTrack, 1, 
        'http://musicbrainz.org/mm/mq-1.1#artistName',
        'http://musicbrainz.org/mm/mq-1.1#albumName',
        'http://musicbrainz.org/mm/mq-1.1#trackName',
        'http://musicbrainz.org/mm/mm-2.1#trmid',
        'http://musicbrainz.org/mm/mm-2.1#trackNum',
        'http://musicbrainz.org/mm/mm-2.1#duration',
        'http://musicbrainz.org/mm/mm-2.1#issued',
        'http://musicbrainz.org/mm/mm-2.1#genre',
        'http://purl.org/dc/elements/1.1/description',
        'http://musicbrainz.org/mm/mm-2.1#link'],
   SubmitTRMList =>
      [\&QuerySupport::SubmitTRMList, 1],
   AuthenticateQuery =>
      [\&QuerySupport::AuthenticateQuery, 0, 
        'http://musicbrainz.org/mm/mq-1.1#username'],
   TrackInfoFromTRMId =>
      [\&QuerySupport::TrackInfoFromTRMId, 0, 
        'http://musicbrainz.org/mm/mm-2.1#trmid',
        'http://musicbrainz.org/mm/mq-1.1#artistName',
        'http://musicbrainz.org/mm/mq-1.1#albumName',
        'http://musicbrainz.org/mm/mq-1.1#trackName',
        'http://musicbrainz.org/mm/mm-2.1#trackNum',
        'http://musicbrainz.org/mm/mm-2.1#duration',
        'http://musicbrainz.org/mm/mq-1.1#fileName'],
   QuickTrackInfoFromTrackId =>
      [\&QuerySupport::QuickTrackInfoFromTrackId, 0, 
        'http://musicbrainz.org/mm/mm-2.1#trackid',
        'http://musicbrainz.org/mm/mm-2.1#albumid'],
   FileInfoLookup =>
      [\&TaggerSupport::FileInfoLookup, 0, 
        'http://musicbrainz.org/mm/mq-1.1#artistName',
        'http://musicbrainz.org/mm/mq-1.1#albumName',
        'http://musicbrainz.org/mm/mq-1.1#trackName',
        'http://musicbrainz.org/mm/mm-2.1#trmid',
        'http://musicbrainz.org/mm/mm-2.1#trackNum',
        'http://musicbrainz.org/mm/mm-2.1#duration',
        'http://musicbrainz.org/mm/mq-1.1#fileName',
        'http://musicbrainz.org/mm/mm-2.1#artistid',
        'http://musicbrainz.org/mm/mm-2.1#albumid',
        'http://musicbrainz.org/mm/mm-2.1#trackid',
        'http://musicbrainz.org/mm/mq-1.1#maxItems']
);  

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

sub Authenticate
{
   my ($session, $session_id, $session_key) = @_;

   if (defined $session_id && $session_id ne '' &&
       defined $session_key && $session_key ne '')
   {
       eval {
          tie %$session, 'Apache::Session::File', $session_id, {
                     Directory => &DBDefs::SESSION_DIR,
                     LockDirectory   => &DBDefs::LOCK_DIR};
       };
       if ($@)
       {
           undef $session_id;
           undef $session_key;
           return "Invalid session id.";
       }
       else
       {
           if ($session->{session_key} ne $session_key)
           {
               tied(%$session)->delete;
               untie %$session;
               return "Invalid session key or invalid password.";
           }
           if ($session->{expire} < time)
           {
               tied(%$session)->delete;
               untie %$session;
               return "Session key expired. Please Authenticate again."; 
           }

           print STDERR "Authenticated session $session_id\n";
	   $session->{expire} = time() + &DBDefs::RDF_SESSION_SECONDS_TO_LIVE;

	   $r->connection->user($session->{moderator})
	   	if $r;

           return "";
       }
   }
   else
   {
       undef $session_id;
       undef $session_key;
       return "Invalid session id and session key provided.";
   }
}

$rdf = MM_2_1->new(0);
$rdf->SetBaseURI("http://" . $ENV{SERVER_NAME});
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

#print STDERR "RDF: $rdfinput\n";

if (!defined $rdf)
{
    $out = $rdf->ErrorRDF("An RDF object must be supplied.");
    Output($r, \$out);
    exit(0);
}

$parser = Parser->new();
if (!$parser->Parse($rdfinput))
{
    $parser->{error} =~ tr/\n\r/  /;
    $parser->{error} =~ s/at \/.*$//;
    $out = $rdf->ErrorRDF("Cannot parse query: $parser->{error}");
    Output($r, \$out);
    exit(0);
}


# Find the toplevel URI
$currentURI = $parser->GetBaseURI();

# Check to see if the client specified a depth for this query. If not,
# use a depth of 2 by default.
$depth = $parser->Extract($currentURI, -1,
                 "http://musicbrainz.org/mm/mq-1.1#depth");
if (not defined $depth)
{
   $depth = 2;
}
if ($depth > 6)
{
    $out = $rdf->ErrorRDF("Query depth cannot be larger than 6!");
    Output($r, \$out);
    exit(0);
}
$rdf->SetDepth($depth);

$session_id = $parser->Extract($currentURI, -1,
                'http://musicbrainz.org/mm/mq-1.1#sessionId');
if (defined $session_id)
{
    my $error;

    $session_key = $parser->Extract($currentURI, -1, 
                   'http://musicbrainz.org/mm/mq-1.1#sessionKey');

    $error = Authenticate(\%session, $session_id, $session_key);
    if ($error ne "")
    {
        $out = $rdf->ErrorRDF($error);
        Output($r, \$out);
        exit(0);
    }
}

# Extract the name of the qyery
$queryname = $parser->Extract($currentURI, -1, 
                 "http://www.w3.org/1999/02/22-rdf-syntax-ns#type");
if (!defined $queryname)
{
    $out = $rdf->ErrorRDF("Cannot determine query name.");
    untie %session unless !defined $session_id;
    Output($r, \$out);
    exit(0);
}

$queryname =~ s/^.*#//;
#print STDERR "query: '$queryname'\n";
 
if (!exists $Queries{$queryname})
{
    $out = $rdf->ErrorRDF("Query '$queryname' is not supported.");
    #print STDERR "$out\n\n";
    untie %session unless !defined $session_id;
    Output($r, \$out);
    exit(0);
}
$querydata = $Queries{$queryname};

$function = shift @$querydata;
$mustauth = shift @$querydata;

if ($mustauth && !defined $session_id)
{
    $out = $rdf->ErrorRDF("You must authenticate to use this query.");
    Output($r, \$out);
    exit(0);
}

for(;;)
{
    $rdfquery = shift @$querydata;
    last if (!defined $rdfquery);

    #print STDERR "$rdfquery: ";
    $data = $parser->Extract($currentURI, -1, $rdfquery);
    $data = undef if (defined $data && $data eq '');
    $data = "" if (defined $data && $data eq "__NULL__");
    #print STDERR "'$rdfquery' ->\n'$data'\n\n" if defined $data;
    push @queryargs, $data;
    $rdfquery = undef;
}

if ($r)
{
	my $uri = "/mm-2.1/$queryname";
	$r->the_request($r->method . " $uri " . $r->protocol);
}

$mb = new MusicBrainz(1);
if (!$mb->Login(1))
{
    $out = $rdf->ErrorRDF("Database Error: ".$DBI::errstr.")");
    untie %session unless !defined $session_id;
    Output($r, \$out);
    exit(0);
}

$rdf->SetDBH($mb->{DBH});
$out = $function->($mb->{DBH}, $parser, $rdf, @queryargs, \%session);
$mb->Logout;


if (!defined $out)
{
    $out = $rdf->ErrorRDF("Query failed (no output)");
}

untie %session unless !defined $session_id;
Output($r, \$out);
