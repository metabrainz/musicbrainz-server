# Relatable will use the following subroutines:
# FindTrackIdByNameAndArtist and CreateTrackGUIDRDFSnippet to obtain
# single Track GUID by Name and Artist.

# returns trackId by Name and Artist
sub FindTrackIdByNameAndArtist
{
   my ($cd, $doc, $name, $artist) = @_;
   my ($sql, $sth, $r, @row, id);

   my $o = $cd->GetCGI;
   $r = RDF::new;

   return EmitErrorRDF("No name or artist search criteria given.")
      if (!defined $name && !define $artist);
   return undef if (!define $cd);

   if ( (defined $name && $name ne '') && (defined $artist && $artist
ne '') )
   {
      # This query finds single track id by name and artist
      $sql = AppendWhereClause($name, "select Track.id, 
from Track, Artist where Track.artist = Artist.id and Artist.name =
$artist and ", "Track.Name");

      $sth = $cd->{DBH}->prepare($sql);
      if ($sth->execute() && $sth->rows)
      {
         # Query should only return one or zero GUIDs
         @row = $sth->fetchrow_array;
         $id = $row[0];
      }
      $sth->finish;

      return CreateTrackGUIDRDFSnippet($cd, $r, $id);
}

# returns single track (including GUID) description
sub CreateTrackGUIDRDFSnippet
{
   my ($cd);
   my ($sth, $rdf, @row, $id, $r);

   $cd = shift @_;
   $r = shift @_;
   my $o = $cd->GetCGI;

   for(;;)
   {
      $id = shift @_;
      last if !defined $id;

      $sth = $cd->{DBH}->prepare("select Track.name, Track.gid,
Track.sequence, Artist.name, Artist.gid, Album.name,
Album.gid, Track.guid from Track, Artist, Album where Track.id = $id
and Track.artist = Artist.id and Track.album = Album.id");
      if ($sth->execute() && $sth->rows)
      {
         while(@row = $sth->fetchrow_array)
         {
            $rdf .= $r->Element("DC:Identifier", "",
                        'artistId'=>$o->escapeHTML($row[4]),
                        'albumId'=>$o->escapeHTML($row[6]),
                        'trackId'=>$o->escapeHTML($row[1]));
            $rdf .= $r->Element("DC:Relation", "",
                        'track'=>($row[2]+1));
            $rdf .= $r->Element("DC:Creator",
                        $o->escapeHTML($row[3]));
            $rdf .= $r->Element("DC:Title",
                        $o->escapeHTML($row[0]));
            $rdf .= $r->Element("MM:Album",
                        $o->escapeHTML($row[5]));
            $rdf .= $r->Element("DC:GUID",
                        $o->escapeHTML($row[7]));
         }
      }
      $sth->finish;
   }

   return $rdf;
}
