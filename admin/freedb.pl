#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use strict;
use DBI;
use DBDefs;
use MusicBrainz;
use Insert;
use File::Copy;
use File::Basename;

my $line;
my $tracks;
my $artist;
my $year;
my $genre;
my $title;
my @ttitles;
my $arg;
my $file;
my $mb;
my $crc;
my $toc;

my $error_dir;

sub ReadOffsets
{
   my $i = 0;
   my $line;
   my $crc;
   my $str;
   my $total;

   while(defined($line = <FILE>))
   {
       if ($line =~ /Disc length:/)
       {
           $line =~ s/^# Disc length: //;
           $line =~ s/ seconds$//;
           chop($line);
           $total .= $line;
           last;  
       }
       $line =~ tr/0-9//cd;
       if ($line eq '')
       {
           next;
       }
       
       $str .= $line . " ";
       $i++
   }

   chop($str);

   $str = "1 $i 0 $str";

   return ($i, $str, $total);
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

sub ReadGenreAndYear
{
   my $line = $_[0];
   my $genre;
   my $year;
   my $saved;

   while(defined($line))
   {
       if (!($line =~ m/^DYEAR/))
       {
          last;
       }

       $line =~ s/DYEAR=//;
       chop($line);
       $saved .= $line;
       $line = <FILE>;
   }

   if($saved eq '') 
   {
       $year = 0;
   }
   else
   {
       $year = $saved;
   }

   $saved = '';
   
   while(defined($line))
   {
       if (!($line =~ m/^DGENRE/))
       {
          last;
       }

       $line =~ s/DGENRE=//;
       chop($line);
       $saved .= $line;
       $line = <FILE>;
   }

   $genre = $saved;

   return ($genre, $year, $line);
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

       $line = $parts[0];
       chop($parts[1]);

       $line =~ tr/0-9//cd;
     
       if ($line eq '')
       {
           printf("Something weird in '$title'. Skipping... (line eq '')\n");
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
           printf("Something weird in '$title'. Skipping... (line ($line) != i ($i)) \n",);
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
   my @track_offsets;
   my $disk_info;
   my $total;
   my $error = 0;
   my ($in, $sql);

   $in = Insert->new($mb->{DBH});
   $sql = Sql->new($mb->{DBH});

   $file = $_[0];

   open(FILE, $file)
      or die "Cannot open $file";

   while(defined($line = <FILE>))
   {
      if (!($line =~ m/Track frame offsets/i))   
      {
         next;
      }

      ($tracks, $toc, $total) = ReadOffsets;
      if (defined($tracks))
      {
          ($title, $artist, $line) = ReadTitleAndArtist;
          if (defined($artist) && defined($title) && defined($line))
          {
              ($genre, $year, $line) = ReadGenreAndYear($line);
              
              my (@data, $tit, @tarray);

              $info{artist} = $artist;
              $info{sortname} = $artist;
              $info{album} = $title;

              $disk_info  = sprintf("artist: \"$info{artist}\"\n");
              $disk_info .= sprintf(" album: \"$info{album}\"\n");
              $disk_info .= sprintf("  year: \"$year\"\n");
              $disk_info .= sprintf("tracks: \n");

              @track_offsets = split(/ /, $toc);
              shift @track_offsets;
              shift @track_offsets;
              shift @track_offsets;
              
              @ttitles = ReadTitles($tracks, $line);
              if (scalar(@ttitles) > 0)
              {   
                  my $tracknum = 1;
                  foreach $tit (@ttitles)
                  {
                     my $duration;
                     if($tracknum < $tracks) 
                     {
                         $duration = int (($track_offsets[$tracknum] - $track_offsets[$tracknum - 1]) / 75);
                     }
                     else 
                     {
                         $duration = $total - (int (($track_offsets[$tracknum - 1]) / 75)) ;
                     }
                     #$disk_info .= sprintf("\t%02d - $tit (%d:%02d)\n", $tracknum, int($duration/60), $duration%60);
                     $disk_info .= sprintf("\t%02d - $tit (%d)\n", $tracknum, $duration);
                     push @tarray, 
                        {
                           track => $tit,
                           tracknum => $tracknum,
                           duration => $duration,
                           year => $year
                        };
                     $tracknum++;
                  }
                  $info{tracks} = \@tarray;
                  eval
                  {
                     $error = 1;
                     print STDERR "Error with \"$file\":\n";
                     print STDERR $in->GetError();
                     print STDERR $disk_info;
                     $sql->Begin;

                     if (!defined $in->Insert(\%info))
                     {
                         print $in->GetError();
                     }
                     $i++;
                     $sql->Commit;
                  };
                  if ($@)
                  {
                     $sql->Rollback;
                     print "Error: $@\n";
                  }
              }
          }
      }
   }

   close FILE;
   
   if($error) 
   {
       my $filename = basename($file);
       my $new_fullname = $error_dir."/".$filename;
       move($file, $new_fullname);
       print STDERR "Moved \"$file\" -> \"$new_fullname\"\n";
   }         

   return $i;
}

sub Recurse
{
    my ($dir) = @_;
    my $count = 0;
    my (@files, $path);
    my $ii = 0;

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
    print("Cannot log into database.\n");
    exit(0);
}

$error_dir = shift;

while($arg = shift)
{
   print "Processing dir $arg\n";
   $count += Recurse($arg);
}
$mb->Logout;
