#!/usr/bin/perl
# UseModWiki upgrade/conversion script.
# Last modified December 10, 2000
# Upgrades version 0.86 or 0.88 wikis to 0.90 data format
# Only the current revision of each page is converted.
# The old author/major copies and the diffs are *not* converted.

# Configuration:
$OldDataDir = ".";   # Old 0.86 or 0.88 DataDir
$DataDir = ".";      # New 0.90 DataDir (must exist when converting)

$PageDir = "$DataDir/page";  # Will be created if necessary

undef $/;  # Read complete files.
$FS = "\xb3"; $FS1 = $FS . "1"; $FS2 = $FS . "2"; $FS3 = $FS . "3";

sub GetPageDirectory {
  my ($id) = @_;

  if ($id =~ /^([a-zA-Z])/) {
    return uc($1);
  }
  return "other";
}

sub GetOldPage {
  my ($id) = @_;
  my ($fname, $data, %FullPage);

  $fname = $OldDataDir . "/" . &GetPageDirectory($id) . "/$id.db";
  if (-f $fname) {
    open(IN, "<$fname") or die "Can't open $fname: $!";
    $data=<IN>;
    close IN;
    %FullPage = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  } else {
    print "error: page $id does not exist.\n";
    %FullPage = ();
  }
  return split(/$FS3/, $FullPage{'current'}, -1);
}

sub AllPagesList {
  my (@pages, @dirs, $id, $dir);

  @dirs = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z other);
  foreach $dir (@dirs) {
    while (<$OldDataDir/$dir/*.db $OldDataDir/$dir/*/*.db>) {
      s|^$OldDataDir\/$dir/||;
      s|\.db$||;
      push(@pages, $_);
    }
  }
  return sort(@pages);
}

sub DoConvert {
  my ($name, $total);

  print "Converting all pages:\n";
  $total = 0;
  foreach $name (&AllPagesList()) {
    %OldPage = &GetOldPage($name);
    if (defined($OldPage{'text'})) {
      &ConvertPage($name);
      $total += length($OldPage{'text'});
    } else {
      print "no text for $name, skipping.\n";
    }
  }
  print "Conversion finished: $total total text bytes.\n";
}

sub ConvertPage {
  my ($id) = @_;
  my ($ts, $rev);

  print "converting $id: " . length($OldPage{'text'}) . " bytes.\n";
  &OpenNewPage($id);
#  foreach (keys %OldPage) {
#    print "|$_| = |$OldPage{$_}|\n";
#  }
#  die "done";
  $ts  = $OldPage{'timestamp'};
  $rev = $OldPage{'revision'};

  $Page{'revision'} = $rev;
  $Page{'tscreate'} = $ts;
  $Page{'ts'} = $ts;

  $Section{'revision'} = $rev;
  $Section{'tscreate'} = $ts;
  $Section{'ts'} = $ts;
  $Section{'ip'} = $OldPage{'logaddr'};
  $Section{'host'} = $OldPage{'logname'};
  $Section{'id'} = $OldPage{'userid'};
  $Section{'username'} = "";  # Not stored in old DB

  $Text{'text'} = $OldPage{'text'};

  &SavePage($id);
}

# New-db subs:
sub OpenNewPage {
  my ($id) = @_;

  %Page = ();
  $Page{'version'} = 3;     # Data format version
  %Section = ();
  $Section{'name'} = 'text_default';
  $Section{'version'} = 1;     # Data format version
  %Text = ();
  $Text{'minor'} = 0;      # Default as major edit
  $Text{'newauthor'} = 1;  # Default as new author
  $Text{'summary'} = '';
}

# Always call SavePage within a lock.
sub SavePage {
  my ($id) = @_;
  my $file = $PageDir . "/" . &GetPageDirectory($id) . "/$id.db";

  &CreatePageDir($PageDir, $id);
  $Section{'data'}      = join($FS3, %Text);
  $Page{'text_default'} = join($FS2, %Section);
  &WriteStringToFile($file, join($FS1, %Page));
}

sub WriteStringToFile {
  my ($file, $string) = @_;

  open (OUT, ">$file") or die ("cant write $file: $!");
  print OUT  $string;
  close(OUT);
}

sub CreateDir {
  my ($newdir) = @_;

  mkdir($newdir, 0775)  if (!(-d $newdir));
}

sub CreatePageDir {
  my ($dir, $id) = @_;
  my $subdir;

  &CreateDir($dir);  # Make sure main page exists
  $subdir = $dir . "/" . &GetPageDirectory($id);
  &CreateDir($subdir);
  if ($id =~ m|([^/]+)/|) {
    $subdir = $subdir . "/" . $1;
    &CreateDir($subdir);
  }
}

&DoConvert();
