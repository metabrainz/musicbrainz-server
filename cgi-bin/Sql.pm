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

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
#use Benchmark;

sub new
{
    my ($type, $dbh) = @_;
    my $this = {};

    $this->{DBH} = $dbh;

    bless $this;
    return $this;
}  

sub Quote
{
    my ($this, $data) = @_;

    return $this->{DBH}->quote($data);
}

sub Select
{
    my ($this, $query) = @_;
    my ($ret, $t0, $t1, $td);
    my ($secs);

    #$t0 = new Benchmark;
    $this->{STH} = $this->{DBH}->prepare($query);
    $ret = $this->{STH}->execute;
    #$t1 = new Benchmark;

    #$td = timediff($t1, $t0);
    #print STDERR (timestr($td, 'nop') . ": $query\n");
    #print STDERR "$query\n";
    if ($ret)
    {
        return $this->{STH}->rows;
    }
    $this->{ERR} = $this->{DBH}->errstr;
    print STDERR "Failed query:\n  '$query' -> " . $this->{DBH}->errstr . "\n";

    $this->{STH}->finish;

    return undef;
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

sub GetError
{
    my ($this) = @_;

    return $this->{ERR};
}

sub Do
{
    my ($this, $query) = @_;
    my $ret;

    #print STDERR "do: $query\n";
    $ret = $this->{DBH}->do($query);
    if ($ret)
    {
       return $ret;
    }
    $this->{ERR} = $this->{DBH}->errstr;
    print STDERR "Failed query:\n  '$query' -> " . $this->{DBH}->errstr . "\n";

    return undef;
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

sub GetLastInsertId
{
   my $this = $_[0];
   my (@row, $sth);

   $sth = $this->{DBH}->prepare("select LAST_INSERT_ID()");
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

sub Begin
{
   my $this = $_[0];

   return $this->{DBH}->begin;
}

sub Commit
{
   my $this = $_[0];

   return $this->{DBH}->commit;
}

sub Rollback
{
   my $this = $_[0];

   return $this->{DBH}->rollback;
}

