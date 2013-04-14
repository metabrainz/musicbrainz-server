#!/usr/bin/env perl

use warnings;
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2002 Robert Kaye
#   Copyright (C) 2012 MetaBrainz Foundation
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

use FindBin;
use lib "$FindBin::Bin/../lib";
use version;

use DBDefs;
use MusicBrainz::Server::Replication ':replication_type';

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my $REPTYPE = DBDefs->REPLICATION_TYPE;

my $psql = "psql";
my $path_to_pending_so;
my $databaseName;
my $fFixUTF8 = 0;
my $fCreateDB;
my $fInstallExtension;
my $fExtensionSchema;
my $tmp_dir;

use Getopt::Long;

my $fEcho = 0;
my $fQuiet = 0;
my $fVerbose = 0;

my $sqldir = "$FindBin::Bin/sql";
-d $sqldir or die "Couldn't find SQL script directory";

sub GetPostgreSQLVersion
{
    my $mb = Databases->get_connection('READWRITE');
    my $sql = Sql->new( $mb->conn );

    my $version = $sql->select_single_value ("SELECT version();");
    $version =~ s/PostgreSQL ([0-9\.]*)(?:beta[0-9]*)? .*/$1/;

    return version->parse ("v".$version);
}

sub RunSQLScript
{
    my ($db, $file, $startmessage, $path) = @_;
    $startmessage ||= "Running $file";
    print localtime() . " : $startmessage ($file)\n" unless $fQuiet;

    $path //= $sqldir;

    my $opts = $db->shell_args;
    my $echo = ($fEcho ? "-e" : "");
    my $stdout;
    my $quiet;

    $ENV{"PGOPTIONS"} = "-c search_path=" . $db->schema . ",public";
    $ENV{"PGPASSWORD"} = $db->password;

    if ($fVerbose)
    {
        $stdout = "";
        $quiet = "";
    }
    else
    {
        $stdout = ">/dev/null";
        $quiet = " --quiet ";
        $ENV{"PGOPTIONS"} .= ' -c client_min_messages=WARNING';
    }

    print "$psql $quiet $echo -f $path/$file $opts 2>&1 $stdout |\n" if $fVerbose;
    open(PIPE, "$psql $quiet $echo -f $path/$file $opts 2>&1 $stdout |")
        or die "exec '$psql': $!";
    while (<PIPE>)
    {
        print localtime() . " : " . $_;
    }
    close PIPE;

    die "Error during $file" if ($? >> 8);
}

sub HasPLPerlSupport
{
    my $mb = Databases->get_connection('READWRITE');
    my $sql = Sql->new( $mb->conn );
    return $sql->select_single_value('SELECT TRUE FROM pg_language WHERE lanname = ?', 'plperlu');
}

sub InstallExtension
{
    my ($db, $ext, $schema) = @_;

    my $opts = "-U postgres " . $db->database;
    my $echo = ($fEcho ? "-e" : "");
    my $stdout = (!$fVerbose ? ">/dev/null" : "");

    my $sharedir = `pg_config --sharedir`;
    die "Cannot find pg_config on path" if !defined $sharedir or $? != 0;

    chomp($sharedir);

    RunSQLScript($db, "$sharedir/contrib/$ext", "Installing $ext extension ...", "");
}

sub CreateReplicationFunction
{
    # Now connect to that database
    my $mb = Databases->get_connection('SYSMB');
    my $sql = Sql->new( $mb->conn );

    $sql->auto_commit;
    $sql->do(
        "CREATE FUNCTION \"recordchange\" () RETURNS trigger
        AS ?, 'recordchange' LANGUAGE 'C'",
        $path_to_pending_so,
    );
}

{
    my $mb;
    my $sql;
    sub get_sql
    {
        my ($name) = shift;
        $mb = Databases->get_connection($name);
        $sql = Sql->new($mb->conn);
    }
}

sub Create
{
    my $createdb = $_[0];
    my $system_sql;

    # Check we can find these programs on the path
    for my $prog (qw( pg_config createuser createdb createlang ))
    {
        next if `which $prog` and $? == 0;
        die "Can't find '$prog' on your PATH\n";
    }

    # Figure out the name of the system database
    my $sysname;
    if ($createdb eq 'READWRITE' || $createdb eq 'READONLY')
    {
        $sysname = "SYSTEM";
    }
    else
    {
        $sysname = $createdb . "_SYSTEM";
        $sysname = "SYSTEM" if not defined Databases->get($sysname);
    }

    my $db = Databases->get($createdb);

    {
        # Check the cluster uses the C locale
        $system_sql = get_sql($sysname);

        my $username = $db->username;

        if (!($system_sql->select_single_value(
            "SELECT 1 FROM pg_shadow WHERE usename = ?", $username)))
        {
            my $passwordclause = "";
            $passwordclause = "PASSWORD '$_'"
                if local $_ = $db->password;

            $system_sql->auto_commit;
            $system_sql->do(
                "CREATE USER $username $passwordclause NOCREATEDB NOCREATEUSER",
            );
        }
    }

    my $dbname = $db->database;
    print localtime() . " : Creating database '$dbname'\n" unless $fQuiet;
    $system_sql->auto_commit;
    my $dbuser = $db->username;
    $system_sql->do(
        "CREATE DATABASE $dbname WITH OWNER = $dbuser ".
        "TEMPLATE template0 ENCODING = 'UNICODE' ".
        "LC_CTYPE='C' LC_COLLATE='C'"
    );

    # You can do this via CREATE FUNCTION, CREATE LANGUAGE; but using
    # "createlang" is simpler :-)
    my $sys_db = Databases->get($sysname);
    my $sys_in_thisdb = $sys_db->meta->clone_object($sys_db, database => $dbname);
    my @opts = $sys_in_thisdb->shell_args;
    splice(@opts, -1, 0, "-d");
    $ENV{"PGPASSWORD"} = $sys_db->password;
    system "createlang", @opts, "plpgsql";
    system "createlang", @opts, "plperlu" if HasPLPerlSupport();
    print "\nFailed to create language -- its likely to be already installed, continuing.\n" if ($? >> 8);

    # Set the default search path for the READWRITE and READONLY users
    my $search_path = $db->schema . ", public";

    if (my $READONLY = Databases->get('READONLY')) {
        _set_search_path($system_sql, $READONLY->username, $search_path);
    }

    _set_search_path($system_sql, $db->username, $search_path);
}

sub _set_search_path {
    my ($sql, $username, $search_path) = @_;

    $sql->auto_commit(1);
    $sql->do(
        "ALTER USER " . $username . " SET search_path TO " . $search_path
    );
}

sub CreateRelations
{
    my $DB = shift;
    my $SYSMB = shift;
    my $import = shift;

    my $opts = $DB->shell_args;
    $ENV{"PGPASSWORD"} = $DB->password;

    system(sprintf("echo \"CREATE SCHEMA %s\" | $psql $opts", $_))
        for ($DB->schema, 'cover_art_archive', 'documentation', 'report', 'statistics', 'wikidocs');
    die "\nFailed to create schema\n" if ($? >> 8);

    if (GetPostgreSQLVersion () >= version->parse ("v9.1"))
    {
        RunSQLScript($SYSMB, "Extensions.sql", "Installing extensions for PostgreSQL 9.1 or newer");
    }
    else
    {
        InstallExtension($SYSMB, "cube.sql", $DB->schema);
    }

    InstallExtension($SYSMB, "musicbrainz_collate.sql", $DB->schema);

    RunSQLScript($DB, "CreateTables.sql", "Creating tables ...");
    RunSQLScript($DB, "caa/CreateTables.sql", "Creating tables ...");
    RunSQLScript($DB, "documentation/CreateTables.sql", "Creating documentation tables ...");
    RunSQLScript($DB, "report/CreateTables.sql", "Creating tables ...");
    RunSQLScript($DB, "statistics/CreateTables.sql", "Creating statistics tables ...");
    RunSQLScript($DB, "wikidocs/CreateTables.sql", "Creating wikidocs tables ...");

    if ($import)
    {
        local $" = " ";
        my @opts = "--ignore-errors";
        push @opts, "--fix-broken-utf8" if ($fFixUTF8);
        push @opts, "--tmp-dir=$tmp_dir" if ($tmp_dir);
        system($^X, "$FindBin::Bin/MBImport.pl", @opts, @$import);
        die "\nFailed to import dataset.\n" if ($? >> 8);
    } else {
        RunSQLScript($DB, "InsertDefaultRows.sql", "Adding default rows ...");
    }

    RunSQLScript($DB, "CreatePrimaryKeys.sql", "Creating primary keys ...");
    RunSQLScript($DB, "caa/CreatePrimaryKeys.sql", "Creating CAA primary keys ...");
    RunSQLScript($DB, "documentation/CreatePrimaryKeys.sql", "Creating documentation primary keys ...");
    RunSQLScript($DB, "statistics/CreatePrimaryKeys.sql", "Creating statistics primary keys ...");
    RunSQLScript($DB, "wikidocs/CreatePrimaryKeys.sql", "Creating wikidocs primary keys ...");

    RunSQLScript($SYSMB, "CreateSearchConfiguration.sql", "Creating search configuration ...");
    RunSQLScript($DB, "CreateFunctions.sql", "Creating functions ...");
    RunSQLScript($DB, "caa/CreateFunctions.sql", "Creating CAA functions ...");

    RunSQLScript($SYSMB, "CreatePLPerl.sql", "Creating system functions ...")
        if HasPLPerlSupport();

    RunSQLScript($DB, "CreateIndexes.sql", "Creating indexes ...");
    RunSQLScript($DB, "caa/CreateIndexes.sql", "Creating CAA indexes ...");
    RunSQLScript($DB, "statistics/CreateIndexes.sql", "Creating statistics indexes ...");

    RunSQLScript($DB, "CreateFKConstraints.sql", "Adding foreign key constraints ...")
        unless $REPTYPE == RT_SLAVE;

    RunSQLScript($DB, "caa/CreateFKConstraints.sql", "Adding CAA foreign key constraints ...")
        unless $REPTYPE == RT_SLAVE;

    RunSQLScript($DB, "CreateConstraints.sql", "Adding table constraints ...")
        unless $REPTYPE == RT_SLAVE;

    RunSQLScript($DB, "SetSequences.sql", "Setting raw initial sequence values ...");
    RunSQLScript($DB, "statistics/SetSequences.sql", "Setting raw initial statistics sequence values ...");

    RunSQLScript($DB, "CreateViews.sql", "Creating views ...");
    RunSQLScript($DB, "caa/CreateViews.sql", "Creating CAA views ...");

    RunSQLScript($DB, "CreateTriggers.sql", "Creating triggers ...")
        unless $REPTYPE == RT_SLAVE;

    RunSQLScript($DB, "caa/CreateTriggers.sql", "Creating CAA triggers ...")
        unless $REPTYPE == RT_SLAVE;

    RunSQLScript($DB, "CreateSearchIndexes.sql", "Creating search indexes ...");

    if ($REPTYPE == RT_MASTER)
    {
        CreateReplicationFunction();
        RunSQLScript($DB, "CreateReplicationTriggers.sql", "Creating replication triggers ...");
        RunSQLScript($DB, "caa/CreateReplicationTriggers.sql", "Creating CAA replication triggers ...");
        RunSQLScript($DB, "documentation/CreateReplicationTriggers.sql", "Creating documentation replication triggers ...");
        RunSQLScript($DB, "statistics/CreateReplicationTriggers.sql", "Creating statistics replication triggers ...");
        RunSQLScript($DB, "wikidocs/CreateReplicationTriggers.sql", "Creating wikidocs replication triggers ...");
    }
    if ($REPTYPE == RT_MASTER || $REPTYPE == RT_SLAVE)
    {
        RunSQLScript($DB, "ReplicationSetup.sql", "Setting up replication ...");
    }

    print localtime() . " : Optimizing database ...\n" unless $fQuiet;
    $opts = $DB->shell_args;
    $ENV{"PGPASSWORD"} = $DB->password;
    system("echo \"vacuum analyze\" | $psql $opts");
    die "\nFailed to optimize database\n" if ($? >> 8);

    print localtime() . " : Initialized and imported data into the database.\n" unless $fQuiet;
}

sub GrantSelect
{
    my $READONLY = Databases->get("READONLY");
    my $READWRITE = Databases->get("READWRITE");

    return unless $READONLY;

    my $name = $_[0];

    my $mb = Databases->get_connection($name);
    my $dbh = $mb->dbh;
    my $sql = Sql->new( $mb->conn );
    $sql->auto_commit;

    my $username = $READONLY->username;
    return if $username eq $READWRITE->username;

    my $sth = $dbh->table_info("", "public") or die;
    while (my $row = $sth->fetchrow_arrayref)
    {
        my $tablename = $row->[2];
        next if $tablename =~ /^(dbmirror_pending|dbmirror_pendingdata)$/;
        $dbh->do("GRANT SELECT ON $tablename TO $username")
            or die;
    }
    $sth->finish;
}

sub SanityCheck
{
    die "The postgres psql application must be on your path for this script to work.\n"
       if not -x $psql and (`which psql` eq '');

    if ($REPTYPE == RT_SLAVE)
    {
        warn "Warning: this is a slave replication server, but there is no READONLY connection defined\n"
            unless Databases->get("READONLY");
    }

    if ($REPTYPE == RT_MASTER)
    {
        defined($path_to_pending_so) or die <<EOF;
Error: this is a master replication server, but you did not specify
the path to "pending.so" (i.e. --with-pending=PATH)
EOF
        if (not -f $path_to_pending_so)
        {
            warn <<EOF;
Warning: $path_to_pending_so not found.
This might be OK for example if you simply don't have permission to see that
file, or if the database server is on a remote host.
EOF
        }
    } else {
        defined($path_to_pending_so) and die <<EOF;
Error: this is not a master replication server, but you specified
the path to "pending.so" (--with-pending=PATH), which makes no sense.
EOF
    }
}

sub Usage
{
   die <<EOF;
Usage: InitDb.pl [options] [file] ...

Options are:
     --psql=PATH         Specify the path to the "psql" utility
     --postgres=NAME     Specify the name of the system user
     --database=NAME     Specify which database to initialize (default: READWRITE)
     --createdb          Create the database, PL/PGSQL language and user
  -i --import            Prepare the database and then import the data from
                         the given files
  -c --clean             Prepare a ready to use empty database
     --[no]echo          When running the various SQL scripts, echo the commands
                         as they are run
  -q, --quiet            Don't show the output of any SQL scripts
  -h --help              This help
  --with-pending=PATH    For use only if this is a master replication server
                         (DBDefs->REPLICATION_TYPE==RT_MASTER).  PATH specifies
                         the path to "pending.so" (on the database server).
     --fix-broken-utf8   replace invalid UTF-8 byte sequences with the special
                         Unicode "replacement character" U+FFFD.
                         (Should only be used, when an import without the option
                         fails with an "ERROR:  invalid UTF-8 byte sequence detected"!
                         see also `MBImport.pl --help')

Less commonly used options:

     --install-extension Install a postgres extension module
     --extension-schema  Which schema to install the extension module into.

After the import option, you may specify one or more MusicBrainz data dump
files for importing into the database. Once this script runs to completion
without errors, the database will be ready to use. Or it *should* at least.

Since all non-option arguments are passed directly to MBImport.pl, you can
pass additional options to that script by using "--".  For example:

  InitDb.pl --createdb --echo --import -- --tmp-dir=/var/tmp *.tar.bz2

EOF
}

my $mode = "MODE_IMPORT";

GetOptions(
    "psql=s"              => \$psql,
    "createdb"            => \$fCreateDB,
    "database:s"          => \$databaseName,
    "empty-database"      => sub { $mode = "MODE_NO_TABLES" },
    "import|i"            => sub { $mode = "MODE_IMPORT" },
    "clean|c"             => sub { $mode = "MODE_NO_DATA" },
    "with-pending=s"      => \$path_to_pending_so,
    "echo!"               => \$fEcho,
    "quiet|q"             => \$fQuiet,
    "verbose|v"           => \$fVerbose,
    "help|h"              => \&Usage,
    "fix-broken-utf8"     => \$fFixUTF8,
    "install-extension=s" => \$fInstallExtension,
    "extension-schema=s"  => \$fExtensionSchema,
    "tmp-dir=s"           => \$tmp_dir
) or exit 2;

$databaseName = "READWRITE" if $databaseName eq '';
my $DB = Databases->get($databaseName);
# Register a new database connection as the system user, but to the MB
# database
my $SYSTEM = Databases->get("SYSTEM");
my $SYSMB  = $SYSTEM->meta->clone_object(
    $SYSTEM,
    database => $DB->database,
    schema => $DB->schema
);
Databases->register_database("SYSMB", $SYSMB);

if ($fInstallExtension)
{
    if (!defined $fExtensionSchema)
    {
        print "You must supply a schema name with the --extension-schema options\n";
    }
    else
    {
        InstallExtension($SYSMB, $fInstallExtension, $fExtensionSchema);
    }
    exit(0);
}

SanityCheck();

print localtime() . " : InitDb.pl starting\n" unless $fQuiet;
my $started = 1;

if ($fCreateDB)
{
    Create($databaseName);
}

if ($mode eq "MODE_NO_TABLES") { } # nothing to do
elsif ($mode eq "MODE_NO_DATA") { CreateRelations($DB, $SYSMB) }
elsif ($mode eq "MODE_IMPORT") { CreateRelations($DB, $SYSMB, \@ARGV) }

GrantSelect("READWRITE") if $databaseName eq "READWRITE";

END {
    print localtime() . " : InitDb.pl "
        . ($? == 0 ? "succeeded" : "failed")
        . "\n"
        if $started;
}

# vi: set ts=4 sw=4 :
