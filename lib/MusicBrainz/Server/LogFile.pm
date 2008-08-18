#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
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

package MusicBrainz::Server::LogFile;

{
	require Exporter;
	our @ISA = qw( Exporter );
	our @EXPORT_OK = qw( lprint lprintf );
	our %EXPORT_TAGS = (
		all => \@EXPORT_OK,	
	);
}

use Fcntl qw( LOCK_EX LOCK_UN );

our %logfiles;

sub RestartHandler
{
    eval
    {
        require Apache;
        require Apache::File;
        require Apache::Table;
    };

    return if $@;

	my $r = shift;

	my @open = $r->dir_config->get("MBLogFile");

	%logfiles = ();

	for my $spec (@open)
	{
		my ($key, $path) = $spec =~ /^(\w+)=(.*)$/
			or do {
				Apache::warn("Ignoring malformed MBLogFile value '$spec'");
				next;
			};

		$logfiles{$key} = undef, next
			if $path eq "/dev/null";

		$path = Apache->server_root_relative($path);

		my $fh = Apache::File->new(">>$path")
			or do {
				Apache::warn("Error opening $path: $!");
				next;
			};
		{ my $o = select $fh; $| = 1; select $o }

		$logfiles{$key} = $fh;
	}
}

sub _get_fh
{
	my $key = shift;
	return \*STDERR unless exists $logfiles{$key};
	return $logfiles{$key};
}

sub lprint($@)
{
	my ($key, @strings) = @_;
	my $fh = _get_fh($key)
		or return;
	my $data = join " ", @strings;
	_spool_data($fh, $data);
}

sub lprintf($$@)
{
	my ($key, $format, @strings) = @_;
	my $fh = _get_fh($key)
		or return;
	my $data = sprintf $format, @strings;
	_spool_data($fh, $data);
}

sub _spool_data
{
	my ($fh, $data) = @_;

	$data = localtime() . " [$$] " . $data;
	$data .= "\n" unless $data =~ /\n\z/;

	flock($fh, LOCK_EX) or return;
	seek($fh, 2, 0) or return;
	print $fh $data;
	flock($fh, LOCK_UN);
}

1;
# eof LogFile.pm
