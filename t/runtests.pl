#!/usr/bin/env perl

use Test::Harness;
use FindBin;
use lib "$FindBin::Bin/../lib";

my @tests;
my $pattern = $ARGV[0];
my $testdir = File::Spec->abs2rel($FindBin::Bin) || ".";

opendir(DIR, $testdir);
while (my $name = readdir(DIR)) {
	if ($name =~ /\.t$/) {
		if (!$pattern || ($name =~ /$pattern/)) {
			push @tests, "$testdir/$name";
		}
	}
}
closedir(DIR);

runtests(@tests);
