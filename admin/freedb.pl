#!/usr/bin/perl -w

use lib "../cgi-bin";
use strict;
use DBI;
use DBDefs;
use MusicBrainz;
use Insert;

my $line;
my $tracks;
my $artist;
my $title;
my @ttitles;
my $arg;
my $file;
my $mb;
my $crc;
my $toc;

sub ReadOffsets
{
   my $i = 0;
   my $line;
   my $crc;
   my $str;

   while(defined($line = <FILE>))
   {
       $line =~ tr/0-9//cd;
       
       if ($line eq '')
       {
           last;
       }
       $str .= $line . " ";
       $i++
   }
   chop($str);

   $str = "1 $i 0 $str";

   return ($i, $str);
}

sub ReadTitleAndArtist
{
   my $i = 0;
   my $line;
   my $artist;
   my $title;
   my $saved;

   while(defined($line = <FILE>))
   {
       if ($line =~ m/^DTITLE/)
       {
           last;
       }
   }
   if (!defined($line))
   {
       print("Got EOF error\n");
       return [];
   }

   while(defined($line))
   {
       if (!($line =~ m/^DTITLE/))
       {
          last;
       }

       $line =~ s/DTITLE=//;
       chop($line);
       $saved .= $line;
       $line = <FILE>;
   }

   ($artist, $title) = split /\//, $saved, 2;
   chop($artist);
   if (!defined($title))
   {
      $title = "(Various)";
   }

   $title =~ s/^ //;

   return ($title, $artist, $line);
}

sub ReadTitles
{
   my $i = 0;
   my $line = $_[1];
   my @titles;
   my @parts;
   my @dummy;

   for($i = 0; $i < $_[0]; $i++)
   {
       if (!defined($line))
       {
           return [];
       }
       @parts = split /=/, $line, 2;
       chop($parts[1]);

       $line = $parts[0];
       $line =~ tr/0-9//cd;
     
       if ($line eq '')
       {
           printf("Something weird in '$title'. Skipping...\n");
           return @dummy
       }
       if ($line == $i - 1)
       {
           $titles[$i - 1] .= $parts[1];
           $i--;
       }
       else
       {
           $titles[$i] = $parts[1];
       }
      
       if ($line != $i)
       {
           printf("Something weird in '$title'. Skipping...\n");
           return @dummy;
       }

       $line = <FILE>;
   }

   return @titles;
}

sub ProcessFile
{
   my $i = 0;
   my $line;
   my %info;
   my $in;

   $in = Insert->new($mb->{DBH});

   $file = $_[0];

   open(FILE, $file)
      or die "Cannot open $file";

   while(defined($line = <FILE>))
   {
      if (!($line =~ m/Track frame offsets/i))   
      {
         next;
      }

      ($tracks, $toc) = ReadOffsets;
      if (defined($tracks))
      {
          ($title, $artist, $line) = ReadTitleAndArtist;
          if (defined($artist) && defined($title) && defined($line))
          {
              my (@data, $tit, @tarray);

              $info{artist} = $artist;
              $info{sortname} = $artist;
              $info{album} = $title;

              @ttitles = ReadTitles($tracks, $line);
              if (scalar(@ttitles) > 0)
              {   
                  my $tracknum = 1;
                  foreach $tit (@ttitles)
                  {
                     push @tarray, 
                        {
                           track => $tit,
                           tracknum => $tracknum
                        };
                     $tracknum++;
                  }
                  $info{tracks} = \@tarray;

                  if (!defined $in->Insert(\%info))
                  {
                     print $in->GetError();
                  }
                  $i++;
              }
          }
      }
   }

   close FILE;
   
   return $i;
}

sub EnterRecord
{
    my $mb = shift @_;
    my $tracks = shift @_;
    my $title = shift @_;
    my $artistname = shift @_;
    my $toc = shift @_;
    my $artist;
    my ($sql, $sql2);
    my $album;
    my ($i, $a, $al, $d, @ids, $num, $t);

    if ($artistname eq '')
    {
        $artistname = "Unknown";
    }

    $a = Artist->new($mb);
    $a->SetName($artistname);
    $artist = $a->Insert();
    if (!defined $artist)
    {
        print "Cannot insert artist.\n";
        exit 0;
    }

    $al = Album->new($mb);
    @ids = $al->FindFromNameAndArtistId($title, $artist);
    for(;defined($album = shift @ids);)
    {
        $num = $al->GetTrackCountFromAlbum($album); 
        last if ($num == $tracks);
    }
    if (!defined $album)
    {
        $album = $al->Insert($title, $artist, $tracks);
        if ($album < 0)
        {
            print "Cannot insert album.\n";
            exit 0;
        }
    }
    for($i = 0; $i < $tracks; $i++)
    {
        $title = shift @_;
        $title = "Unknown" if $title eq '';

        $t = Track->new($mb);
        $t->Insert($title, $artist, $album, $i + 1);
        $d = Diskid->new($mb);
        $d->Insert("", $album, $toc);
    }
}

sub Recurse
{
    my ($dir) = @_;
    my $count = 0;
    my (@files, $path);

    opendir(DIR, $dir) or die "Can't open $dir";
    @files = readdir(DIR);
    closedir(DIR);

    foreach $file (@files)
    {
        next if ($file eq '.' || $file eq '..');

        $path = $dir . "/" . $file;
        if (-d $path)
        {
            $count += Recurse($path);
            next;
        }
        print "Import: '$path'\n";
        $count += ProcessFile($path);
    }

    return $count;
}

my $count = 0;

$mb = MusicBrainz->new;
if (!$mb->Login)
{
    printf("Cannot log into database.\n");
    exit(0);
}

while($arg = shift)
{
   print "Processing dir $arg\n";
   $count += Recurse($arg);
}
$mb->Logout;
