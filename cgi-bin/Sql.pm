#____________________________________________________________________________
#
#   MusicBrainz -- the open music metadata database
#
#   Copyright (C) 2001 Robert Kaye
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
                                                                               
package Sql;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Benchmark::Timer;
use Carp qw(cluck);

sub new
{
    my ($type, $dbh) = @_;
    my $this = {};

    $this->{DBH} = $dbh;

    bless $this;
    return $this;
}  

# Allow one auto commit transaction!
sub AutoCommit
{
    my ($this) = @_;
  
    $this->{AutoCommit} = 1;
}

sub Quote
{
    my ($this, $data) = @_;

    return $this->{DBH}->quote($data);
}

sub Select
{
    my ($this, $query) = @_;
    my ($ret, $t);

    $ret = eval
    {
       #print STDERR "SELECT: $query\n";
       $t = Benchmark::Timer->new(skip => 0);
       $t->start('start');

       $this->{STH} = $this->{DBH}->prepare($query);
       $ret = $this->{STH}->execute;

       $t->stop;
       if ($t->result('start') > 2.00)
       {
           print STDERR "--------------------------------------------\n";
           print STDERR "$query\n";
           $t->report;
       }
       
       return $this->{STH}->rows;
    };
    if ($@)
    {
        my $err = $@;

        $this->{STH}->finish;
        $this->{ERR} = $this->{DBH}->errstr;
        cluck("Failed query:\n  '$query'\n$err\n");
        die $err;
    }
    return $ret;
}

sub Finish
{
    my ($this) = @_;

    $this->{STH}->finish;
}

sub Rows
{
    my ($this) = @_;

    $this->{STH}->rows;
}

sub NextRow
{
    my ($this) = @_;

    return $this->{STH}->fetchrow_array;
}

sub NextRowRef
{
    my ($this) = @_;

    return $this->{STH}->fetch;
}

sub GetError
{
    my ($this) = @_;

    return $this->{ERR};
}

sub Do
{
    my ($this, $query) = @_;
    my $ret;

    if (exists $this->{AutoCommit} && $this->{AutoCommit} == 1)
    {
        $this->{AutoCommit} = 0;
        $this->{DBH}->{AutoCommit} = 1;
    }
    elsif ($this->{DBH}->{AutoCommit} == 1)
    {
        cluck("AutoCommit is turned on!");
        die "AutoCommit on!"
    }
#    die "No transaction started in Do." if ($this->{DBH}->{AutoCommit} == 0);
#    my (@ltime, $trace, $prefix, @strace, $q);
#    $trace = Carp::longmess();
    
#    @ltime = localtime(time());
#    $prefix = ($ltime[5]+1900) . ($ltime[4]+1) . $ltime[3] . ": ";
    
#    @strace = split /^/m, $trace;
#    $trace = $prefix . join $prefix, $strace[0], $strace[1], $strace[2];

#    $q = $query;
#    $q =~ s/\n/ /g;
#    print STDERR "$prefix $q\n$trace";
#    print STDERR "DO: $query\n";

    $ret = eval
    {
        $this->{DBH}->do($query);
        return 1;
    };
    if ($@)
    {
        my $err = $@;

        $this->{ERR} = $this->{DBH}->errstr;
        cluck("Failed query:\n  '$query'\n$err\n");
        die $err;
    }
    return $ret;
}

sub GetSingleRow
{
    my ($this, $tab, $cols, $where) = @_;
    my (@row, $query, $count);

    $query = "select " . join(", ", @$cols) . " from $tab";
    if (scalar(@$where) > 0)
    {
       for($count = 0; scalar(@$where) > 1; $count++)
       {
           if ($count == 0)
           {
               $query .= " where ";
           }
           else
           {
               $query .= " and ";
           }
           $query .= (shift @$where) . " = " .  (shift @$where);
       }
    }
    if ($this->Select($query))
    {
        @row = $this->NextRow;
        $this->Finish;

        return @row;
    }
    return undef;
}

# This function is just like GetSingleRow, but the first pair or
# where clause items is compared with ILIKE, and not a simple =
sub GetSingleRowLike
{
    my ($this, $tab, $cols, $where) = @_;
    my (@row, $query, $count);

    $query = "select " . join(", ", @$cols) . " from $tab";
    if (scalar(@$where) > 0)
    {
       for($count = 0; scalar(@$where) > 1; $count++)
       {
           if ($count == 0)
           {
               $query .= " where " . (shift @$where) . " ilike " .  
                         (shift @$where);
           }
           else
           {
               $query .= " and " . (shift @$where) . " = " .  
                         (shift @$where);
           }
       }
    }
    if ($this->Select($query))
    {
        @row = $this->NextRow;
        $this->Finish;

        return @row;
    }
    return undef;
}

sub GetLastInsertId
{
   my ($this, $table) = @_;
   my (@row, $sth);

   $sth = $this->{DBH}->prepare("select currval('" . $table ."_id_seq')");
   if ($sth->execute && $sth->rows)
   {
       @row = $sth->fetchrow_array;
       $sth->finish;

       return $row[0];
   }
   $sth->finish;

   return undef;
}

sub GetSingleColumn
{
    my ($this, $tab, $col, $where) = @_;
    my (@row, $query, $count, @col);

    $query = "select $col from $tab";
    if (scalar(@$where) > 0)
    {
       for($count = 0; scalar(@$where) > 1; $count++)
       {
           if ($count == 0)
           {
               $query .= " where ";
           }
           else
           {
               $query .= " and ";
           }
           $query .= (shift @$where) . " = " .  (shift @$where);
       }
    }
    if ($this->Select($query))
    {
        while(@row = $this->NextRow)
        {
            push @col, $row[0];
        }
        $this->Finish;

        return @col;
    }
    return ();
}

sub GetSingleColumnLike
{
    my ($this, $tab, $col, $where) = @_;
    my (@row, $query, $count, @col);

    $query = "select $col from $tab";
    if (scalar(@$where) > 0)
    {
       for($count = 0; scalar(@$where) > 1; $count++)
       {
           if ($count == 0)
           {
               $query .= " where " . (shift @$where) . " ilike " .  
                         (shift @$where);
           }
           else
           {
               $query .= " and " . (shift @$where) . " = " .  
                         (shift @$where);
           }
       }
    }
    if ($this->Select($query))
    {
        while(@row = $this->NextRow)
        {
            push @col, $row[0];
        }
        $this->Finish;

        return @col;
    }
    return ();
}

sub Begin
{
   my $this = $_[0];

   $this->{DBH}->{AutoCommit} = 0;
}

sub Commit
{
   my $this = $_[0];

   my $ret = eval
   {
       my $rv = $this->{DBH}->commit;
       cluck("Commit failed") if ($rv eq '');
       return $rv;
   };
   if ($@)
   {
       my $err = $@;
       cluck($err);
       die $err;
   }
   return $ret;
}

sub Rollback
{
   my $this = $_[0];

   my $ret = eval
   {
       my $rv = $this->{DBH}->rollback;
       cluck("Rollback failed") if ($rv eq '');
       return $rv;
   };
   if ($@)
   {
       my $err = $@;
       cluck($err);
       die $err;
   }
   return $ret;
}

