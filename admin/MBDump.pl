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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use strict;
use DBI;
use DBDefs;

my $dbname = DBDefs::DB_NAME;
my $dbuser = DBDefs::DB_USER;

use Getopt::Long;

my $sDefaultOutputFile = "mbdump.tar.bz2";
my $sDefaultTmpDir = "/tmp";

sub Usage
{
   die <<EOF;
Usage: MBDump.pl [options] [tables]

Options are:
  -c, --core          Dump the core tables (album, track, etc)
  -d, --derived       Dump the derived tables (words, artistwords, ... )
  -m, --moderation    Dump the other tables (moderator, votes, stats, ...)
                      except for "artist_relation"
  -s, --[no]sanitised [Don't] sanitise the "moderator" table.
                      If you're dumping the moderator table you *must* specify
                      either --sanitised or --nosanitised
  -o, --outfile       Output filename (default: $sDefaultOutputFile)
  -t, --tmpdir        Temporary directory to use (default: $sDefaultTmpDir)
  -f, --format=FORMAT Dump format: "postgres" (the default), "pg_copy",
                      "excelcsv", "mysql"
  -h, --help          This help
      --debug         If there's a problem, don't remove the temporary files
                      on exit

After the options, you may specify individual table names.  Using the table
selection options (--core etc) simply adds to that list of tables.

The data in --core is placed in the public domain.  All other data
is licensed under a Creative Commons license:
    http://creativecommons.org/licenses/by-nc-sa/1.0

The --derived data is, by definition, solely derivable from the --core data.
All other data is under --moderation, except for the "artist_relation" table.

You must not mix PD-licensed and CC-licensed tables in a single dump.

EOF
}

my ($fSanitised, $fCore, $fDerived, $fModeration);
my $outfile = $sDefaultOutputFile;
my $tmpdir = $sDefaultTmpDir;
my $fHelp;
my $fDebug;
my $sFormat = "postgres";

GetOptions(
	"sanitised|sanitized|s!"	=> \$fSanitised,
	"core|c"		=> \$fCore,
	"derived|d"		=> \$fDerived,
	"moderation|m"	=> \$fModeration,
	"outfile|o=s"	=> \$outfile,
	"tmpdir|t=s"	=> \$tmpdir,
	"help|h"		=> \$fHelp,
	"debug"			=> \$fDebug,
	"format|f=s"	=> \$sFormat,
);

Usage() if ($fHelp);

Usage() unless $sFormat =~ /\A(postgres|pg_copy|excelcsv|mysql)\z/;

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
	albummeta
	albumwords
	artistwords
	trackwords
	wordlist
	);

my @moderation = qw(
    clientversion
	currentstat
	historicalstat
	moderation
	moderationnote
	moderator
	stats
	votes
	);

# NOTE: Not in any of those groups: artist_relation

push @ARGV, @core if $fCore;
push @ARGV, @derived if $fDerived;
push @ARGV, @moderation if $fModeration;

@ARGV or Usage();

my %tables = map { lc($_) => 1 } @ARGV;
my @tables = sort keys %tables;



# Work out what license to use for this data.  Don't allow a mixture.

my $sLicense;

for my $t (@tables)
{
	my $fUsePD = grep { $t eq $_ } @core;
	my $sThisLicense = $fUsePD ? "PD" : "CC";
	die "Error: cannot dump data using a mixture of licenses.\n"
		if defined $sLicense and $sLicense ne $sThisLicense;
	$sLicense = $sThisLicense;
}

$sLicense or die "Huh?  Can't work out what license we're using";



# Moderator table: check and obey the "--sanitised" argument.

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
		$sql->Do("UPDATE moderator_sanitised SET password = 'mb', privs = 0, email = ''");
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

$| = 1;
for (@tables)
{
	eval { $sql->SelectSingleValue("SELECT 1 FROM $_ LIMIT 1"); 1 }
		or warn("No such table '$_', skipping...\n"), next;
	DumpTable($_) or exit 1;
}

# Add the misc files

system("date > $dir/timestamp");

OutputPublicDomainDedication("$dir/COPYING") if $sLicense eq "PD";
OutputLicense("$dir/COPYING") if $sLicense eq "CC";

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
        eval { $sql->Do("DROP TABLE moderator_sanitised") }
			if $tables{"moderator_sanitised"};
    	undef $sql;
     	$mb->Logout;
    }
	system("/bin/rm", "-rf", $dir) unless ($fDebug || not defined $dir);
}



sub DumpTable
{
	return DumpTable_pg_copy(@_) if $sFormat eq "pg_copy";
	return DumpTable_excelcsv(@_) if $sFormat eq "excelcsv";
	return DumpTable_mysql(@_) if $sFormat eq "mysql";
    my $table = shift;

    my $cmd = "pg_dump -U $dbuser -Fc -t $table $dbname > $dir/$table";
    my $ret = system($cmd) >>8;

    print "Dumped table $table.\n";

    return !$ret;
}

sub OutputLicense
{
    my ($file) = @_;

    my $text = <<'END';
-----------------------------------------------------------------------------

    This work is licensed under the Creative Commons Attribution-NonCommercial-
ShareAlike License.

                 Attribution-NonCommercial-ShareAlike 1.0

Key License Terms:

Attribution:   The licensor permits others to copy, distribute, display, and 
               perform the work. In return, licensees must give the original 
               author credit.
Noncommercial: The licensor permits others to copy, distribute, display, and 
               perform the work. In return, licensees may not use the work 
               for commercial purposes -- unless they get the licensor's 
               permission.
Share Alike:   The licensor permits others to distribute derivative works only 
               under a license identical to the one that governs the licensor's 
               work.

Whoever has associated this Commons Deed with their copyrighted work licenses 
his or her work to you on the terms of the Creative Commons License found below.

-----------------------------------------------------------------------------
License

THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE 
COMMONS PUBLIC LICENSE ("CCPL" OR "LICENSE"). THE WORK IS PROTECTED BY 
COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF THE WORK OTHER THAN AS 
AUTHORIZED UNDER THIS LICENSE IS PROHIBITED.

BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO 
BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS 
CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND 
CONDITIONS.

1. Definitions

   1. "Collective Work" means a work, such as a periodical issue, anthology 
      or encyclopedia, in which the Work in its entirety in unmodified form, 
      along with a number of other contributions, constituting separate and 
      independent works in themselves, are assembled into a collective whole. 
      A work that constitutes a Collective Work will not be considered a 
      Derivative Work (as defined below) for the purposes of this License.
   2. "Derivative Work" means a work based upon the Work or upon the Work 
      and other pre-existing works, such as a translation, musical arrangement,
      dramatization, fictionalization, motion picture version, sound recording,
      art reproduction, abridgment, condensation, or any other form in which 
      the Work may be recast, transformed, or adapted, except that a work that 
      constitutes a Collective Work will not be considered a Derivative Work 
      for the purpose of this License.
   3. "Licensor" means the individual or entity that offers the Work under the 
      terms of this License.
   4. "Original Author" means the individual or entity who created the Work.
   5. "Work" means the copyrightable work of authorship offered under the 
      terms of this License.
   6. "You" means an individual or entity exercising rights under this License 
      who has not previously violated the terms of this License with respect 
      to the Work, or who has received express permission from the Licensor 
      to exercise rights under this License despite a previous violation.

2. Fair Use Rights. Nothing in this license is intended to reduce, limit, or 
   restrict any rights arising from fair use, first sale or other limitations 
   on the exclusive rights of the copyright owner under copyright law or other 
   applicable laws.

3. License Grant. Subject to the terms and conditions of this License, 
   Licensor hereby grants You a worldwide, royalty-free, non-exclusive, 
   perpetual (for the duration of the applicable copyright) license to 
   exercise the rights in the Work as stated below:

   1. to reproduce the Work, to incorporate the Work into one or more 
      Collective Works, and to reproduce the Work as incorporated in the 
      Collective Works;
   2. to create and reproduce Derivative Works;
   3. to distribute copies or phonorecords of, display publicly, perform 
      publicly, and perform publicly by means of a digital audio 
      transmission the Work including as incorporated in Collective Works;
   4. to distribute copies or phonorecords of, display publicly, perform 
      publicly, and perform publicly by means of a digital audio transmission 
      Derivative Works;

   The above rights may be exercised in all media and formats whether now known 
   or hereafter devised. The above rights include the right to make such 
   modifications as are technically necessary to exercise the rights in other 
   media and formats. All rights not expressly granted by Licensor are hereby 
   reserved.

4. Restrictions. The license granted in Section 3 above is expressly made 
   subject to and limited by the following restrictions:

   1. You may distribute, publicly display, publicly perform, or publicly 
      digitally perform the Work only under the terms of this License, and 
      You must include a copy of, or the Uniform Resource Identifier for, this 
      License with every copy or phonorecord of the Work You distribute, 
      publicly display, publicly perform, or publicly digitally perform. You 
      may not offer or impose any terms on the Work that alter or restrict the 
      terms of this License or the recipients' exercise of the rights granted 
      hereunder. You may not sublicense the Work. You must keep intact all 
      notices that refer to this License and to the disclaimer of warranties. 
      You may not distribute, publicly display, publicly perform, or publicly 
      digitally perform the Work with any technological measures that control 
      access or use of the Work in a manner inconsistent with the terms of 
      this License Agreement. The above applies to the Work as incorporated in 
      a Collective Work, but this does not require the Collective Work apart 
      from the Work itself to be made subject to the terms of this License. 
      If You create a Collective Work, upon notice from any Licensor You must, 
      to the extent practicable, remove from the Collective Work any reference 
      to such Licensor or the Original Author, as requested. If You create a 
      Derivative Work, upon notice from any Licensor You must, to the extent 
      practicable, remove from the Derivative Work any reference to such 
      Licensor or the Original Author, as requested.
   2. You may distribute, publicly display, publicly perform, or publicly 
      digitally perform a Derivative Work only under the terms of this 
      License, and You must include a copy of, or the Uniform Resource 
      Identifier for, this License with every copy or phonorecord of each 
      Derivative Work You distribute, publicly display, publicly perform, or 
      publicly digitally perform. You may not offer or impose any terms on 
      the Derivative Works that alter or restrict the terms of this License 
      or the recipients' exercise of the rights granted hereunder, and You 
      must keep intact all notices that refer to this License and to the 
      disclaimer of warranties. You may not distribute, publicly display, 
      publicly perform, or publicly digitally perform the Derivative Work with 
      any technological measures that control access or use of the Work in a 
      manner inconsistent with the terms of this License Agreement. The above 
      applies to the Derivative Work as incorporated in a Collective Work, 
      but this does not require the Collective Work apart from the Derivative 
      Work itself to be made subject to the terms of this License.
   3. You may not exercise any of the rights granted to You in Section 3 
      above in any manner that is primarily intended for or directed toward 
      commercial advantage or private monetary compensation. The exchange of 
      the Work for other copyrighted works by means of digital file-sharing or 
      otherwise shall not be considered to be intended for or directed toward 
      commercial advantage or private monetary compensation, provided there 
      is no payment of any monetary compensation in connection with the 
      exchange of copyrighted works.
   4. If you distribute, publicly display, publicly perform, or publicly 
      digitally perform the Work or any Derivative Works or Collective Works, 
      You must keep intact all copyright notices for the Work and give the 
      Original Author credit reasonable to the medium or means You are 
      utilizing by conveying the name (or pseudonym if applicable) of the 
      Original Author if supplied; the title of the Work if supplied; in the 
      case of a Derivative Work, a credit identifying the use of the Work in 
      the Derivative Work (e.g., "French translation of the Work by Original 
      Author," or "Screenplay based on original Work by Original Author"). 
      Such credit may be implemented in any reasonable manner; provided, 
      however, that in the case of a Derivative Work or Collective Work, at 
      a minimum such credit will appear where any other comparable authorship 
      credit appears and in a manner at least as prominent as such other 
      comparable authorship credit.

5. Representations, Warranties and Disclaimer

   1. By offering the Work for public release under this License, Licensor 
      represents and warrants that, to the best of Licensor's knowledge after 
      reasonable inquiry:

         1. Licensor has secured all rights in the Work necessary to grant 
            the license rights hereunder and to permit the lawful exercise of 
            the rights granted hereunder without You having any obligation to 
            pay any royalties, compulsory license fees, residuals or any 
            other payments;
         2. The Work does not infringe the copyright, trademark, publicity 
            rights, common law rights or any other right of any third party 
            or constitute defamation, invasion of privacy or other tortious 
            injury to any third party.
   2. EXCEPT AS EXPRESSLY STATED IN THIS LICENSE OR OTHERWISE AGREED IN 
      WRITING OR REQUIRED BY APPLICABLE LAW, THE WORK IS LICENSED ON AN 
      "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR 
      IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES REGARDING THE 
      CONTENTS OR ACCURACY OF THE WORK.

6. Limitation on Liability. EXCEPT TO THE EXTENT REQUIRED BY APPLICABLE LAW, 
   AND EXCEPT FOR DAMAGES ARISING FROM LIABILITY TO A THIRD PARTY RESULTING 
   FROM BREACH OF THE WARRANTIES IN SECTION 5, IN NO EVENT WILL LICENSOR BE 
   LIABLE TO YOU ON ANY LEGAL THEORY FOR ANY SPECIAL, INCIDENTAL, 
   CONSEQUENTIAL, PUNITIVE OR EXEMPLARY DAMAGES ARISING OUT OF THIS 
   LICENSE OR THE USE OF THE WORK, EVEN IF LICENSOR HAS BEEN ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGES.

7. Termination

   1. This License and the rights granted hereunder will terminate 
      automatically upon any breach by You of the terms of this License. 
      Individuals or entities who have received Derivative Works or Collective 
      Works from You under this License, however, will not have their licenses 
      terminated provided such individuals or entities remain in full 
      compliance with those licenses. Sections 1, 2, 5, 6, 7, and 8 will 
      survive any termination of this License.
   2. Subject to the above terms and conditions, the license granted here 
      is perpetual (for the duration of the applicable copyright in the 
      Work). Notwithstanding the above, Licensor reserves the right to 
      release the Work under different license terms or to stop distributing 
      the Work at any time; provided, however that any such election will 
      not serve to withdraw this License (or any other license that has 
      been, or is required to be, granted under the terms of this License), 
      and this License will continue in full force and effect unless 
      terminated as stated above.

8. Miscellaneous

   1. Each time You distribute or publicly digitally perform the Work or a 
      Collective Work, the Licensor offers to the recipient a license to 
      the Work on the same terms and conditions as the license granted to 
      You under this License.
   2. Each time You distribute or publicly digitally perform a Derivative 
      Work, Licensor offers to the recipient a license to the original Work 
      on the same terms and conditions as the license granted to You under 
      this License.
   3. If any provision of this License is invalid or unenforceable under 
      applicable law, it shall not affect the validity or enforceability of 
      the remainder of the terms of this License, and without further action 
      by the parties to this agreement, such provision shall be reformed to 
      the minimum extent necessary to make such provision valid and enforceable.
   4. No term or provision of this License shall be deemed waived and no 
      breach consented to unless such waiver or consent shall be in writing 
      and signed by the party to be charged with such waiver or consent.
   5. This License constitutes the entire agreement between the parties with 
      respect to the Work licensed here. There are no understandings, 
      agreements or representations with respect to the Work not specified 
      here. Licensor shall not be bound by any additional provisions that 
      may appear in any communication from You. This License may not be 
      modified without the mutual written agreement of the Licensor and You.
END

   open(OUT, ">$file")
    or die("cannot open $file\n");

   print OUT $text;
   close(OUT);
}

sub OutputPublicDomainDedication
{
    my ($file) = @_;

    my $text = <<'END';
-----------------------------------------------------------------------------

This work is hereby released into the Public Domain. To view a copy of 
the public domain dedication, visit 

            http://creativecommons.org/licenses/publicdomain 
    
or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, 
California 94305, USA. 

-----------------------------------------------------------------------------
               P U B L I C   D O M A I N   D E D I C A T I O N

            Copyright-Only Dedication (based on United States law)


This is a record of a Public Domain Dedication.

On February 10, 2003, MusicBrainz Community dedicated to the public domain 
the work "MusicBrainz Core Data." Before making the dedication, MusicBrainz 
Community represented that MusicBrainz Community owned all copyrights in the
work. By making the dedication, MusicBrainz Community made an overt act
of relinquishment in perpetuity of all present and future rigths under
copyright law, whether vested or contingent, in "MusicBrainz Core Data."

MusicBrainz Community understands that such relinquishment of all rights
includes the relinquishment of all rights to enforce (by lawsuit or
otherwise) those copyrights in the Work.

MusicBrainz Community recognizes that, once placed in the public domain,
"MusicBrainz Core Data" may be freely reproduced, distributed, transmitted, 
used, modified, built upon, or otherwise exploited by anyone for any
purpose, commercial or non-commercial, and in any way, including by
methods that have not yet been invented or conceived.

-----------------------------------------------------------------------------
END

    open(OUT, ">$file")
       or die("cannot open $file\n");

    print OUT $text;
    close(OUT);
}

sub DumpTable_pg_copy
{
    my $table = shift;
	my $dbh = $sql->{DBH};

	$sql->AutoCommit;
	$sql->Do("COPY $table TO stdout");

	open(DUMP, ">$dir/$table") or die $!;
	print "$table ... " if -t STDOUT;
	my $row = 0;

	my $buffer;
	while ($dbh->func($buffer, 10000, 'getline'))
	{
		print DUMP $buffer, "\n";
		++$row;
		print $row, chr(8) x length($row)
			if -t STDOUT
			and not $row % 1000;
	}

	close DUMP;
	$dbh->func('endcopy');
	print "$row\n" if -t STDOUT;
}

sub DumpTable_excelcsv
{
    my $table = shift;
	my $dbh = $sql->{DBH};

	$sql->AutoCommit;
	$sql->Do("COPY $table TO stdout");

	open(DUMP, ">$dir/$table.csv") or die $!;
	binmode DUMP;
	print "$table ... " if -t STDOUT;
	my $row = 0;

	my $buffer;
	while ($dbh->func($buffer, 10000, 'getline'))
	{
		my @f = split /\t/, $buffer, -1;
		for (@f) { $_ = undef, next if $_ eq '\N'; s/\\t/\t/g; s/\\n/\n/g; s/\\\\/\\/g; }
		for (@f)
		{
			$_ = "", next unless defined;
			next unless /[,"\015\012]/;
			tr/\015//d;
			s/"/""/g;
			$_ = qq["$_"];
		}
		print DUMP join(",", @f), "\015\012";
		++$row;
		print $row, chr(8) x length($row)
			if -t STDOUT
			and not $row % 1000;
	}

	close DUMP;
	$dbh->func('endcopy');
	print "$row\n" if -t STDOUT;
}

sub DumpTable_mysql
{
    my $table = shift;
	my $dbh = $sql->{DBH};

	#open(CREATE, ">$dir/$table-data.sql") or die $!;
	#print CREATE "DROP TABLE IF EXISTS $table;\n";
	#print CREATE "CREATE TABLE $table (\n";
	## TODO get column info
	#print CREATE "\n);\n";
	#close CREATE;

	$sql->AutoCommit;
	$sql->Do("COPY $table TO stdout");

	open(DUMP, ">$dir/$table-data.sql") or die $!;
	print DUMP "TRUNCATE TABLE $table;\n";
	print "$table ... " if -t STDOUT;
	my $row = my $tot = 0;

	my $dumpevery = 5000;
	$dumpevery = 1000 if $table eq "toc";

	my $buffer;
	while ($dbh->func($buffer, 10000, 'getline'))
	{
		my @f = split /\t/, $buffer, -1;
		for (@f) { $_ = undef, next if $_ eq '\N'; s/\\t/\t/g; s/\\n/\n/g; s/\\\\/\\/g; }
		for (@f)
		{
			$_ = "NULL", next unless defined;
			next if /\A\d+\z/;

			# Munge dates into MySQL format (remove ".ms" and "+TZ")
			# TODO only apply this transformation to things which are
			# actually date columns
			s/\A(\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d)(?:\.\d+)?(?:\+\d\d)?\z/$1/;

			s/([\\'])/\\$1/g;
			s/\n/\\n/g;
			$_ = qq['$_'];
		}

		print DUMP "INSERT INTO $table VALUES\n"
			if $row == 0;
		print DUMP ",\n" if $row;

		print DUMP "(", join(",", @f), ")";
		++$row; ++$tot;
		print $tot, chr(8) x length($tot)
			if -t STDOUT
			and not $tot % 1000;

		unless ($row % $dumpevery)
		{
			print DUMP ";\n";
			$row = 0;
		}
	}

	print DUMP ";\n" if $row;
	close DUMP;
	$dbh->func('endcopy');
	print "$tot\n" if -t STDOUT;
}

# eof MBDump.pl
