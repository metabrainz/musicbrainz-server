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
use Sql;
use Artist;
use UUID;

sub new
{
    my ($type, $dbh) = @_;
    my $this = {};

    # Use the db handle from the musicbrainz object
    $this->{DBH} = $dbh;
    $this->{type} = $type;

    bless $this;
    return $this;
}  

sub GetDBH
{
    return $_[0]->{DBH}; 
}

sub SetDBH
{
    $_[0]->{DBH} = $_[1]; 
}

sub GetId
{
   return $_[0]->{id};
}

sub SetId
{
   $_[0]->{id} = $_[1];
}

sub GetName
{
   return $_[0]->{name};
}

sub SetName
{
   $_[0]->{name} = $_[1];
}

sub GetMBId
{
   return $_[0]->{mbid};
}

sub SetMBId
{
   $_[0]->{mbid} = $_[1];
}

sub GetModPending
{
   return $_[0]->{modpending};
}

sub SetModPending
{
   $_[0]->{modpending} = $_[1];
}

sub GetNewInsert
{
   return $_[0]->{new_insert};
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
    my ($uuid, $id);

    UUID::generate($uuid);
    UUID::unparse($uuid, $id);

    return $id;
}  

sub Escape 
{
  $_[0] =~ s/&/&amp;/g;  # & first of course
  $_[0] =~ s/</&lt;/g;
  $_[0] =~ s/>/&gt;/g;
  return $_[0];
}

