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
                                                                               
package TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
    my ($type, $mb) = @_;
    my $this = {};

    # Use the db handle from the musicbrainz object
    $this->{DBH} = $mb->{DBH};

    # Save the MB object as well
    $this->{MB} = $mb;

    # This will contain the data for a table row
    $this->{data} = {};

    # This will contain the last error code
    $this->{err} = "";

    # The deriving classes should set the table name into this value
    $this->{table} = "";

    # The deriving classes should set the value of this to the 
    # columns that they want to retrieve from the table
    $this->{cols} = "";

    $this->{type} = $type;

    bless $this;
    return $this;
}  

sub GetLastInsertId
{
   my $this = $_[0];
   my (@row, $sth);

   $sth = $this->{DBH}->prepare("select LAST_INSERT_ID()");
   $sth->execute;
   if ($sth->rows)
   {
       @row = $sth->fetchrow_array;
       $sth->finish;

       return $row[0];
   }
   $sth->finish;

   return -1;
}    

sub LoadFromId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $sth = $this->{DBH}->prepare("select " . $this->{col} . " from " .
                                $this->{table} . " where id=$id");
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
        $rv = 1;
   }
   else
   {
       $rv = 0;
   }
   $sth->finish;

   return $rv;
}

sub LoadFromGID
{
   my ($this, $gid) = @_;
   my ($sth, $rv);

   $gid = $this->{DBH}->quote($gid);
   $sth = $this->{DBH}->prepare("select " . $this->{col} . " from " .
                                $this->{table} . " where gid=$gid");
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
        $rv = 1;
   }
   else
   {
       $rv = 0;
   }
   $sth->finish;

   return $rv;
}

sub LoadFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, $rv);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare("select " . $this->{col} . " from " .
                                $this->{table} . " where guid=$guid");
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
        $rv = 1;
   }
   else
   {
       $rv = 0;
   }
   $sth->finish;

   return $rv;
}

sub FindTextInColumn
{
    my ($this, $table, $column, $search) = @_;
    my ($sql, $sth, @idslabels, @row, $i);

    $sql = AppendWhereClause($this, $search, "select id, $column from $table ".
                             "where ", $column) . " order by $column limit 25";

    $sth = $this->{DBH}->prepare($sql);
    $sth->execute();
    if ($sth->rows > 0)
    {
        for($i = 0; @row = $sth->fetchrow_array; $i++)
        {
            push @idslabels, $row[0];
            push @idslabels, $row[1];
        }
    }

    return @idslabels;
} 

sub AppendWhereClause
{
    my ($this, $search, $sql, $col) = @_;
    my (@words, $i);

    $search =~ tr/A-Za-z0-9/ /cs;
    $search =~ tr/A-Z/a-z/;
    @words = split / /, $search;

    $i = 0;
    foreach (@words)
    {
       if (length($_) > 1)
       {
          if ($i++ > 0)
          {
             $sql .= " and ";
          }
          $sql .= "instr(lower($col), '" . $_ . "') <> 0";
       }
       else
       {
          if ($i++ > 0)
          {
             $sql .= " and ";
          }
          $sql .= "lower($col) regexp  '([[:<:]]+|[[:punct:]]+)" .
                  $_ . "([[:punct:]]+|[[:>:]]+)'";
       }
    }

    return $sql;
} 

sub CreateNewGlobalId
{
    my ($this) = @_;
    my ($sth, $id, @row);

    $this->{DBH}->do("lock tables GlobalId write");

    $sth = $this->{DBH}->prepare("select MaxIndex, Host from GlobalId");
    $sth->execute();
    if ($sth->rows > 0)
    {
        @row = $sth->fetchrow_array;
        $id = sprintf('%08X@%s@%08X', $row[0], $row[1], time);
        $row[0]++;
        $this->{DBH}->do("update GlobalId set MaxIndex = $row[0]");
    }
    $sth->finish;
    $this->{DBH}->do("unlock tables");

    return $id;
}  

sub Value
{
    my ($this, $field) = @_;

    return $this->{data}[$field];
}

sub Escape 
{
  $_[0] =~ s/&/&amp;/g;  # & first of course
  $_[0] =~ s/</&lt;/g;
  $_[0] =~ s/>/&gt;/g;
  return $_[0];
}

1;
