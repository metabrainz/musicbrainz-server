#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :

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

		if (eval { $class->_LoadFromFilehandle($fh, $sql); 1 })
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
	my ($class, $fh, $sql) = @_;

	my %type;

	my %trm;
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

	while (my ($trm, $usecount) = each %trm)
	{
		$sql->Do(
			"UPDATE trm SET lookupcount = lookupcount + ? WHERE trm = ?",
			$usecount, $trm,
		);

		++$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";

	printf "%s : Applying updates - %d artist alias uses\n",
		scalar(localtime),
		scalar(keys %artistalias);

	$n = keys %artistalias;
	$i = 0;
	$t0 = [ gettimeofday ];

	while (my ($aliasid, $t) = each %artistalias)
	{
		my @gmt = gmtime $t->{LASTTIME};
		$gmt[4]++;
		$gmt[5]+=1900;
		my $timestr = sprintf('%04d-%02d-%02d %02d:%02d:%02d', @gmt[5,4,3,2,1,0]);

		$sql->Do("
			UPDATE artistalias SET timesused = timesused + ?,
				lastused = CASE
					WHEN ? > lastused THEN ?
					ELSE lastused
				END
			WHERE id = ?
			",
			$t->{USECOUNT},
			$timestr, $timestr,
			$aliasid,
		);

		++$i % 100 or $p->(), print "\r"
			if -t STDOUT;
	}

	$p->(); print "\n";
}

1;
# eof DeferredUpdate.pm
