#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use lib "../cgi-bin";
use DBI;
use DBDefs;

use Getopt::Long;

sub Usage
{
   die <<EOF;
Usage: MBDump.pl [options] [tables]

Options are:
  -c, --core          Dump the core tables (album, track, etc)
  -d, --derived       Dump the derived tables (words, stats)
  -m, --moderation    Dump the moderation tables (moderator, votes, ...)
  -a, --all           Implies --core --derived --moderation
  -s, --[no]sanitised [Don't] sanitise the "moderator" table.
                      If you're dumping the moderator table you *must* specify
                      either --sanitised or --nosanitised
  -o, --outfile       Output filename (default: $sDefaultOutputFile)
  -t, --tmpdir        Temporary directory to use (default: $sDefaultTmpDir)
  -h, --help          This help
      --debug         If there's a problem, don't remove the temporary files
                      on exit

After the options, you may specify individual table names.  Using the table
selection options (--core etc) simply adds to that list of tables.

EOF
}

my ($fAll, $fSanitised, $fCore, $fDerived, $fModeration);
my $outfile = my $sDefaultOutputFile = "mbdump.tar.bz2";
my $tmpdir = my $sDefaultTmpDir = "/tmp";
my $fHelp;
my $fDebug;

GetOptions(
	"all|a"			=> \$fAll,
	"sanitised|sanitized|s!"	=> \$fSanitised,
	"core|c"		=> \$fCore,
	"derived|d"		=> \$fDerived,
	"moderation|m"	=> \$fModeration,
	"outfile|o=s"	=> \$outfile,
	"tmpdir|t=s"	=> \$tmpdir,
	"help|h"		=> \$fHelp,
	"debug"			=> \$fDebug,
);

Usage() if ($fHelp);

require MusicBrainz;
my $mb = MusicBrainz->new;
$mb->Login or die;

require Sql;
my $sql = Sql->new($mb->{DBH});

my @core = qw(
	album
	albumjoin
	artist
	artistalias
	discid
	toc
	track
	trm
	trmjoin
	);

my @derived = qw(
	albumwords
	artistwords
	stats
	trackwords
	wordlist
	);

my @moderation = qw(
	moderation
	moderationnote
	moderator
	votes
	);

push @ARGV, @core if $fCore or $fAll;
push @ARGV, @derived if $fDerived or $fAll;
push @ARGV, @moderation if $fModeration or $fAll;

@ARGV or Usage();

my %tables = map { lc($_) => 1 } @ARGV;
my @tables = sort keys %tables;

if ($tables{"moderator"})
{
	defined($fSanitised) or die <<EOF;
When dumping the moderator table, you must specify either
--sanitised or --nosanitised
EOF

	if ($fSanitised)
	{
		# Sanitise the moderator table.
		# This is somewhat suboptimal, since the dump that's generated
		# then contains a table called "moderator_sanitised", not "moderator".
		# That's just the way pg_dump works I suppose.  I would have preferred
		# to have ended up with a table still called "moderator", just with
		# certain data missing.  So properly importing the sanitised dump file
		# is left as an exercise for the reader.
		# Dave Evans, 2002-11-10

		delete $tables{"moderator"};
		++$tables{"moderator_sanitised"};

        # Most of the time, this table shouldn't exist, so lets suppress
        # the warning message so it won't bug the users
        #$sql->Quiet(1);
		$sql->AutoCommit;
		eval { $sql->Do("DROP TABLE moderator_sanitised") };
        #$sql->Quiet(0);
		
		$sql->AutoCommit;
		$sql->Do("SELECT * INTO moderator_sanitised FROM moderator");

		$sql->AutoCommit;
		$sql->Do("UPDATE moderator_sanitised SET password = '', privs = 0, email = ''");
	}
}

# Refresh the array in case we changed the %tables hash above
@tables = sort keys %tables;

print "Dumping tables: @tables\n";

# Here we go!

my $dir = "$tmpdir/mbdump";

system("/bin/rm", "-rf", $dir);

mkdir($dir, 0700)
  or die("Cannot create tmp directory $dir.\n");

chmod 0777, $dir;

# Dump the tables

for (@tables)
{
	DumpTable($_) or exit 1;
}

# Add the misc files

system("date > $dir/timestamp");
OutputLicense("$dir/COPYING");

# Tar it all up

print "Creating tar archive...\n";
system("tar -C $tmpdir -c mbdump | bzip2 -c > $outfile");
exit $? if $?;

system("/bin/rm", "-rf", $dir);

exit;

END
{
    if (defined $sql)
    {
        $sql->AutoCommit;
        eval { $sql->Do("DROP TABLE moderator_sanitised") };
    	undef $sql;
     	$mb->Logout;
    }
	system("/bin/rm", "-rf", $dir) unless ($fDebug || not defined $dir);
}



sub DumpTable
{
    my $table = shift;

    $cmd = "pg_dump -Fc -t $table musicbrainz > $dir/$table";
    $ret = system($cmd) >>8;

    print "Dumped table $table.\n";

    return !$ret;
}

sub OutputLicense
{
    my ($file) = @_;

    $text = <<END;
OpenContent License (OPL)
Version 1.0, July 14, 1998. 

This document outlines the principles underlying the OpenContent (OC) movement and may be redistributed provided it remains unaltered. For legal purposes, this document is the license under which OpenContent is made available for use. 

The original version of this document may be found at http://opencontent.org/opl.shtml 

LICENSE 

Terms and Conditions for Copying, Distributing, and Modifying 

Items other than copying, distributing, and modifying the Content with which this license was distributed (such as using, etc.) are outside the scope of this license. 

  1. You may copy and distribute exact replicas of the OpenContent (OC) as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the absence of any warranty; and give any other recipients of the OC a copy of this License along with the OC. You may at your option charge a fee for the media and/or handling involved in creating a unique copy of the OC for use offline, you may at your option offer instructional support for the OC in exchange for a fee, or you may at your option offer warranty in exchange for a fee. You may not charge a fee for the OC itself. You may not charge a fee for the sole service of providing access to and/or use of the OC via a network (e.g. the Internet), whether it be via the world wide web, FTP, or any other method. 

  2. You may modify your copy or copies of the OpenContent or any portion of it, thus forming works based on the Content, and distribute such modifications or work under the terms of Section 1 above, provided that you also meet all of these conditions: 

  a) You must cause the modified content to carry prominent notices stating that you changed it, the exact nature and content of the changes, and the date of any change. 

  b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the OC or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License,
  unless otherwise permitted under applicable Fair Use law. 

  These requirements apply to the modified work as a whole. If identifiable sections of that work are not derived from the OC, and can be reasonably considered independent and separate works in themselves, then this License, and its terms, do not apply to those sections when you distribute them as separate works. But when you distribute the same sections as part of a whole which is a work based on the OC, the distribution of the whole must be on the terms of this License, whose permissions for other licensees extend to the entire whole, and thus to each and every part regardless of who wrote it. Exceptions are made to this requirement to release modified works free of charge under this license only in compliance with Fair Use law where applicable. 

  3. You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to copy, distribute or modify the OC. These actions are prohibited by law if you do not accept this License. Therefore, by distributing or translating the OC, or by deriving works herefrom, you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or translating the OC. 

  NO WARRANTY 

  4. BECAUSE THE OPENCONTENT (OC) IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE OC, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE OC "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE OF THE OC IS WITH YOU. SHOULD THE OC PROVE FAULTY, INACCURATE, OR OTHERWISE UNACCEPTABLE YOU ASSUME THE COST OF ALL NECESSARY REPAIR OR CORRECTION. 

  5. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MIRROR AND/OR REDISTRIBUTE THE OC AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE OC, EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
END

   open(OUT, ">$file")
    or die("cannot open $file\n");

   print OUT $text;
   close(OUT);
}
