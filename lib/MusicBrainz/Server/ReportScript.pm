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

use strict;
use warnings;

package MusicBrainz::Server::ReportScript;

use MusicBrainz;
use Sql;
use Getopt::Long;
use MusicBrainz::Server::PagedReport;
use FindBin;
use Carp;

sub ReportName { ref($_[0]) || $_[0] }
sub HTMLIndexFile { $FindBin::Bin . "/" . $_[0]->ReportName . ".inc" }

sub new
{
	my $self = shift;
	bless +{}, ref($self) || $self;
}

sub DBH			: lvalue { $_[0]{dbh} }
sub SqlObj		: lvalue { $_[0]{SQL} }
sub PagedReport	: lvalue { $_[0]{REPORT} }
sub LogFH		: lvalue { $_[0]{LOG_FH} }
sub ReportDir	: lvalue { $_[0]{REPORT_DIR} }

sub Log
{
	my $self = shift;
	my $msg = "@_";
	chomp $msg;
	print { $self->LogFH } localtime(). " : $msg\n";
}

sub Logf
{
	$_[0]->Log(sprintf $_[1], @_[2..$#_]);
}

# The main entry point for each report.  Each is run using the idiom:
# __PACKAGE__->new->RunReport

sub RunReport
{
	my $self = shift;

	# Open database connection, report and log files.
	# Note, can't $self->Log yet, because we don't know about --verbose etc
	$self->_Init;

	# Open a report file.
	$self->Log("Opening report file");
	$self->OpenReport;

	# Filter the result relation and write everything that survived.
	$self->Log("Gathering data");
	$self->GatherData;

	# Create index.html.
	$self->Log("Creating index file");
	$self->CreateIndexFile;

	# Close connection to database, report and log file.
	$self->Log("Finishing");
	$self->Finish;

	$self->Log("Done");
}

# Initialise; read command-line options, open the report file, connect to the
# database.  Any subclassing should be added to "Init", not "_Init".

sub _Init
{
	my $self = shift;

	my $verbose = -t;
	my $dir;

	GetOptions(
		'output-dir=s'	=>	\$dir,
		'verbose!'		=>	\$verbose,
	) or exit 2;
	die "Bad options\n" if @ARGV;
	die "Bad options\n" unless defined $dir;

	mkdir $dir
		or $!{'EEXIST'}
		or die "Couldn't create report dir: $dir: $!\n";
	$self->ReportDir = $dir;

	my $fh;
	$verbose
		? open($fh, ">&STDOUT")
		: open($fh, '>/dev/null');
	$self->LogFH = $fh;
	$self->Log("Starting");

	# Get a connection to the database.
	my $mb = MusicBrainz->new;
	$mb->Login;
	# We don't need the MB object, but we need to prevent it from being
	# destroyed, since its DESTROY method disconnects us from the database.
	$self->{_keep_mb_} = $mb;

	my $sql = Sql->new($mb->{dbh});
	$self->SqlObj = $sql;
	$self->DBH = $mb->{dbh};

	$self->Init;

	$self->Log("Init done");
}

sub Init { }

# Open the report file for writing

sub OpenReport
{
	my $self = shift;
	my $dir = $self->ReportDir;
	my $report = MusicBrainz::Server::PagedReport->Save("$dir/report");
	$self->PagedReport = $report;
}

# Find whatever data we need, and write it into the report file

# GatherData is abstract, and might well be implemented in terms of
# GatherDataFromQuery.
sub GatherData;

sub GatherDataFromQuery
{
	my ($self, $query, $args, $filter) = @_;
	$args ||= [];

	$self->Log("Querying database");
	my $sql = $self->SqlObj;
	$sql->Select($query, @$args);

	$self->Log("Saving results");
	my $report = $self->PagedReport;
	while (my $row = $sql->NextRowHashRef)
	{
		next if $filter and not($row = &$filter($row));
		$report->Print($row);
	}

	$self->Log("Query complete");
	$sql->Finish;
}

# Create the "index.html" file in the output directory.
# The default implementation copies "<report name>.inc".

sub CreateIndexFile
{
	my $self = shift;

	use File::Copy qw( copy );
	copy($self->HTMLIndexFile, $self->ReportDir . "/index.html")
		or die "copy: $!";
}

# Finish off; close files etc.

sub Finish
{
	my $self = shift;

	my $report = $self->PagedReport;
	$report->End if $report;
}

1;
# eof ReportScript.pm
