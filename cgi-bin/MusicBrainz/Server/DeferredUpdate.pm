#!/usr/bin/perl -w
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

1;
# eof DeferredUpdate.pm
