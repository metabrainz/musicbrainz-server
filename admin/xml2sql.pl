#!/usr/bin/perl -w

package XMLDBI;
use DBI qw/:sql_types/;
use XML::Parser;

use vars qw(@ISA @EXPORT $table $dbh $sth);

@ISA= ("XML::Parser");

sub IsNumber {
	my ($value) = @_;

	return ($value =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/); # Regexp taken from the perlfaq4
}

sub new {
	my($proto) = shift @_;
	my($class) = ref($proto) || $proto;
	my($self) = $class->SUPER::new(@_);

	my $driver = shift;
	my $datasource = shift;
	my $userid = shift;
	my $passwd = shift;
	$table = shift; # Not sure if we want to limit to individual tables yet
	my $dbname = shift;

	bless($self, $class);
	$self->setHandlers('Start' => $self->can('Start'),
						'Init' => $self->can('Init'),
						'End'  => $self->can('End'),
						'Char' => $self->can('Char'),
						'Proc' => $self->can('Proc'),
						'Final' =>$self->can('Final'),
						);

	# Setup the DB Connection

	$dbh = DBI->connect("dbi:$driver:$datasource", $userid, $passwd) or die "Can't connect to datasource";
	if ($dbname) {
		$dbh->do("use $dbname") || die $dbh->errstr;
	}

	return($self);
}

sub execute {
	my ($self, $sql) = @_;
	$dbh->do($sql);
}

sub Init {
	my $expat = shift;

	# OK, here we setup the insert statement.
	# We use the prepare method because it offers us _very_ fast inserts.

	$sth = $dbh->prepare("select * from $table where 1=2") || die $dbh->errstr;
	$sth->execute() || die $dbh->errstr; # Get column names
	my $names = $sth->{NAME};

	my $sql = "insert into $table ( " . (join ", ", @$names) . " ) values ( ";
	my $colnum = 1;
	eval {
		$sql .= (join ", ",
					(map {
							$expat->{ __PACKAGE__ . "columns"}->{uc($_)} = $colnum++;
							'?';
						} @{$names})
				);
		};
	if ($@) {
		die $@;
	}

	$sql .= " )";
print $sql, "\n\n";
	$sth = $dbh->prepare($sql) || die;

#	my $count = 1;
#	foreach my $f (keys(%{$expat->{ __PACKAGE__ . "columns"}})) {
#		$sth->bind_param( $count++ , undef );
#	}

	# Possibly add begin transaction code here.
}

sub Start {
	my ($expat, $element, %attrs) = @_;
	# Structure goes: DSN->Table->Column
	if ($expat->within_element("ROW")) {
		# OK, got a column, reset the data within that column
		undef $expat->{ __PACKAGE__ . "currentData"};
	}
}

sub End {
	my ($expat, $element) = @_;
	if ($element eq "ROW") {
		# Found the end of a row
		print "Inserting a row...\n";
		$sth->execute() || die;

		# Re-bind to undef (makes sure things are NULL)
		my $count = 1;
		foreach my $f (keys(%{$expat->{ __PACKAGE__ . "columns"}})) {
			$sth->bind_param( $count++ , undef );
		}
	}
	elsif ($expat->within_element("ROW")) {
		# A column
		$element = uc($element);
		return unless $expat->{ __PACKAGE__ . "columns"}->{$element};
		if (IsNumber($expat->{ __PACKAGE__ . "currentData"})) {
			if( $expat->{ __PACKAGE__ . "currentData"} =~ /\./ ) {
				$sth->bind_param($expat->{ __PACKAGE__ . "columns"}->{$element}, $expat->{ __PACKAGE__ . "currentData"}, SQL_FLOAT);
			}
			else {
				$sth->bind_param($expat->{ __PACKAGE__ . "columns"}->{$element}, $expat->{ __PACKAGE__ . "currentData"}, SQL_INTEGER);
			}
		}
		else {
			$sth->bind_param($expat->{ __PACKAGE__ . "columns"}->{$element}, $expat->{ __PACKAGE__ . "currentData"}, SQL_VARCHAR);
		}
	}
}

sub Char {
	my ($expat, $string) = @_;
	# The only Char is the data. (AFAIK) Otherwise this will break (sorry!)
	my @context = $expat->context;
	my $column = pop @context;
	my $curtable = pop @context;
	if ($curtable eq "ROW") {
		$expat->{ __PACKAGE__ . "currentData"} .= $string;
	}
}

sub Proc {
    my $expat = shift;
    my $target = shift;
    my $text = shift;
}

sub Final {
    my $expat = shift;

	# Possibly put commit code here.
}

1;
#########################################################################################

package main;
use strict;
use Getopt::Long;
use vars qw($datasource $userid $password $table $inputfile $help
			$dbname $verbose $truncate $driver);

sub usage;
sub quote;
sub IsNumber;

# Options to variables mapping
my %optctl = (
	'sn' => \$datasource,
	'uid' => \$userid,
	'pwd' => \$password,
	'table' => \$table,
	'input' => \$inputfile,
	'help' => \$help,
	'db' => \$dbname,
	'verbose' => \$verbose,
	'x' => \$truncate,
	'driver' => \$driver,
	);

# Option types
my @options = (
			"sn=s",
			"uid=s",
			"pwd=s",
			"table=s",
			"input=s",
			"db=s",
			"driver=s",
			"help",
			"verbose",
			"x"
			);

GetOptions(\%optctl, @options) || die "Get Options Failed";

usage if $help;

unless ($datasource and $userid and $table and $inputfile) {
	usage;
}

$driver = $driver || "ODBC"; # ODBC is the default driver. Change this if you want.

my $xmldb = XMLDBI->new($driver, $datasource, $userid, $password, $table, $dbname);

if ($truncate) {
	$xmldb->execute("DELETE FROM $table");
}

open(FILE, $inputfile) or die $!;
my $file = join "", <FILE>;

$xmldb->parsestring($file);

# End

####################################################################
### subs ###

sub usage {
	print <<EOF;
Usage:
    xls2sql.pl {Options}

    where options are:

        Option   ParamName     ParamDesc
        -sn      servername    Data source name
		[-driver dbi_driver]   Driver that DBI uses. Defaults to ODBC
        -uid     username      Username
        -pwd     password      Password
        -table   tablename     Table to extract
        -input   inputfile     File to get input from (excel file)
        [-x]                   Delete from table first
        [-db     dbname]       Sybase database name
        [-v or --verbose]      Verbose output
EOF
	exit;
}

