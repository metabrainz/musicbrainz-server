#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

use strict;

package MusicBrainz::Server::DeferredUpdate;

sub Write
{
	my ($class, $type, @args) = @_;
	
	my $f = &DBDefs::DEFERRED_UPDATE_LOG;

	open(my $fh, ">>", $f)
		or warn("open >>$f: $!"), return;

	unshift @args, time(), $type;
   
	print $fh gmtime() . "\t" . join("\t", @args) . "\n"
		or warn("print $f: $!");

	close $fh
		or warn("close $f: $!");
}

sub LoadFiles
{
	my ($class) = @_;
	
	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	
	require Sql;
	my $sql = Sql->new($mb->{DBH});

	local $SIG{INT} = sub { die "SIGINT!\n" };

	for my $file (@ARGV)
	{
		print localtime() . " : Loading $file\n";

		open(my $fh, "<", $file)
			or warn("open $file: $!\n"), next;

		$sql->Begin;

		if (eval { $class->_LoadFromFilehandle($fh, $mb->{DBH}); 1 })
		{
			$sql->Commit;
			print localtime() . " : Successfully loaded $file\n";
			close $fh;
			unlink $file
				or warn("Loaded $file but couldn't remove it: $!\n");
		} else {
			my $err = $@;
			$sql->Rollback;
			print STDERR localtime() . " : Failed to load $file ($err)\n";
			close $fh;
			rename $file, "$file.failed-".time()
				or warn("Loaded $file but couldn't rename it: $!\n");
		}
	}
}

sub _LoadFromFilehandle
{
	my ($class, $fh, $dbh) = @_;

	my %type;

	my %trm;
	my %trmusage;
	my %artistalias;

	while (<$fh>)
	{
		chomp;
		my ($gmtime, $time, $type, @args) = split /\t/, $_, -1;

		++$type{$type};

		if ($type eq "TRM::IncrementLookupCount")
		{
			++$trm{$args[0]};
		}
		elsif ($type eq "TRM::IncrementUsageCount")
		{
			++$trmusage{"$args[0],$args[1]"};
		}
		elsif ($type eq "Alias::UpdateLookupCount")
		{
			my $table = lc $args[0];
			lc($table) eq "artistalias" or die "table = $table";

			my $t = ($artistalias{$args[1]} ||= { USECOUNT => 0, LASTTIME => 0 });
			++$t->{USECOUNT};
			$t->{LASTTIME} = $time;
		}
		else
		{
			warn "Don't understand update type '$type' (@args)";
		}
	}

	# ------------------------------------------------------
	printf "%s : Applying updates - %d TRM lookups\n",
		scalar(localtime),
		scalar(keys %trm);

	use Time::HiRes qw( gettimeofday tv_interval );

	my ($n, $i, $t0);
	my $p = sub {
		my $t = tv_interval($t0);
		printf "%s : %6d rows ; %3d%% ; %d rows/sec",
			scalar(localtime),
			$i, int(100 * $i / ($n||1)), $i/$t,
			;
	};

	$n = keys %trm;
	$i = 0;
	$t0 = [ gettimeofday ];
	require TRM;
	my $trmobj = TRM->new($dbh);

	while (my ($trm, $usecount) = each %trm)
	{
		$trmobj->UpdateLookupCount($trm, $usecount);
		++$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";

	# ------------------------------------------------------
	printf "%s : Applying updates - %d TRM usage\n",
		scalar(localtime),
		scalar(keys %trmusage);

	use Time::HiRes qw( gettimeofday tv_interval );

	$p = sub {
		my $t = tv_interval($t0);
		printf "%s : %6d rows ; %3d%% ; %d rows/sec",
			scalar(localtime),
			$i, int(100 * $i / ($n||1)), $i/$t,
			;
	};

	$n = keys %trmusage;
	$i = 0;
	$t0 = [ gettimeofday ];
	$trmobj = TRM->new($dbh);

	while (my ($args, $usecount) = each %trmusage)
	{
		my ($trm, $trackid) = split /,/, $args;
		$trmobj->UpdateUsageCount($trm, $trackid, $usecount);
		++$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";

	# ------------------------------------------------------
	printf "%s : Applying updates - %d artist alias uses\n",
		scalar(localtime),
		scalar(keys %artistalias);

	$n = keys %artistalias;
	$i = 0;
	$t0 = [ gettimeofday ];

	require Alias;
	my $aliasobj = Alias->new($dbh, "artistalias");

	while (my ($aliasid, $t) = each %artistalias)
	{
		my @gmt = gmtime $t->{LASTTIME};
		$gmt[4]++;
		$gmt[5]+=1900;
		my $timestr = sprintf('%04d-%02d-%02d %02d:%02d:%02d', @gmt[5,4,3,2,1,0]);
		$aliasobj->UpdateLastUsedDate($aliasid, $timestr, $t->{USECOUNT});
		++$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";
}

1;
# eof DeferredUpdate.pm
