#!/usr/bin/perl -w
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
		$class->LoadFile($sql, $file);
	}
}

sub LoadFile
{
	my ($class, $sql, $file) = @_;

	open(my $fh, "+<", $file)
		or do {
			warn  "open $file: $!\n" unless $!{ENOENT};
			next;
		};
	print localtime() . " : Loading $file\n";

	require IO::Handle;
	$fh->autoflush;

	for (;;)
	{
		my $seek = $class->_GetSeekFromFH($fh);

		if ($seek >= -s($fh))
		{
			print localtime() . " : Successfully loaded $file\n";
			unlink $file or warn $!;
			close $fh;
			last;
		}

		my $newseek;

		print localtime() . " : Trying $file from ".(0+$seek)."\n";

		eval {
			$sql->Begin;
			$class->_LoadFromFilehandle($fh, $sql->{DBH}, $seek, \$newseek);
			$sql->Commit;
		};

		if ($@ eq "")
		{
			$class->_SetSeekInFH($newseek, $fh);
		} else {
			my $err = $@;
			eval { $sql->Rollback };

			if ($err =~ /\b deadlock \b/xi)
			{
				print localtime() . " : Deadlock detected - sleeping...\n";
				sleep 10;
			} else {
				chomp $err;
				print localtime() . " : Error: $err\n";
				print localtime() . " : Ignoring the rest of this file\n";
				return if $err =~ /SIGINT/;
				last;
			}
		}
	}
}

use POSIX qw( SEEK_SET );

sub _GetSeekFromFH
{
	my ($class, $fh) = @_;

	seek($fh, 0, SEEK_SET) or die $!;
	my $line = <$fh>;
	return $1 if defined($line) and $line =~ /^SEEK=(\d+)$/;
	return 0;
}

sub _SetSeekInFH
{
	my ($class, $seek, $fh) = @_;
	seek($fh, 0, SEEK_SET) or die $!;
	print $fh "SEEK=".(0+$seek)."\n";
}

sub _LoadFromFilehandle
{
	my ($class, $fh, $dbh, $seek, $newseekref) = @_;

	seek($fh, $seek, SEEK_SET) or die $!;
	printf "%s : Starting at seek=%s (%d%%)\n",
		scalar localtime,
		$seek,
		100 * $seek / -s($fh);

	my $lines = 0;

	my %type;

	my %artistalias;

	while (<$fh>)
	{
		chomp;
		my ($gmtime, $time, $type, @args) = split /\t/, $_, -1;

		++$type{$type};

		if ($type eq "Alias::UpdateLookupCount")
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

		++$lines;
		last if $lines >= 100;
	}

	$$newseekref = tell($fh);
	print localtime() . " : Stopping at seek=$$newseekref (after $lines lines)\n";

	my $sql = Sql->new($dbh);
	my ($n, $i, $t0);

	use Time::HiRes qw( gettimeofday tv_interval );

	my $p = sub {
		my $t = tv_interval($t0);
		printf "%s : %6d rows ; %3d%% ; %d rows/sec",
			scalar(localtime),
			$i, int(100 * $i / ($n||1)), $i/$t,
			;
	};

	# ------------------------------------------------------
	printf "%s : Applying updates - %d artist alias uses\n",
		scalar(localtime),
		scalar(keys %artistalias);

	$n = keys %artistalias;
	$i = 0;
	$t0 = [ gettimeofday ];

	require MusicBrainz::Server::Alias;
	my $aliasobj = MusicBrainz::Server::Alias->new($dbh, "artistalias");

	while (my ($aliasid, $t) = each %artistalias)
	{
		my @gmt = gmtime $t->{LASTTIME};
		$gmt[4]++;
		$gmt[5]+=1900;
		my $timestr = sprintf('%04d-%02d-%02d %02d:%02d:%02d', @gmt[5,4,3,2,1,0]);
		$aliasobj->UpdateLastUsedDate($aliasid, $timestr, $t->{USECOUNT});
		++$i;
		$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";
}

1;
# eof DeferredUpdate.pm
