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

package Alias;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use SearchEngine;

sub new
{
   my ($type, $dbh, $table) = @_;

   my $this = TableBase->new($dbh);
   $this->{table} = lc $table;

   return bless $this, $type;
}

# Artist specific accessor function. Others are inherted from TableBase
sub GetTable
{
   return $_[0]->{table};
}

sub SetTable
{
   $_[0]->{table} = $_[1];
}

sub GetRowId
{
   return $_[0]->{rowid};
}

sub SetRowId
{
   $_[0]->{rowid} = $_[1];
}

sub GetLastUsed
{
   return $_[0]->{lastused};
}

sub SetLastUsed
{
   $_[0]->{lastused} = $_[1];
}

sub GetTimesUsed
{
   return $_[0]->{timesused};
}

sub SetTimesUsed
{
   $_[0]->{timesused} = $_[1];
}

sub LoadFromId
{
    my ($this) = @_;
    my $sql = Sql->new($this->{DBH});
   
    my $row = $sql->SelectSingleRowArray(
        "SELECT id, name, ref, lastused, timesused
        FROM artistalias
        WHERE id = ?",
        $this->GetId,
    ) or return undef;

    @$this{qw(
        id name rowid lastused timesused
    )} = @$row;

    return 1;
}

# To insert a new alias, this function needs to be passed the alias id
# and an alias name.
sub Insert
{
   my ($this, $id, $name) = @_;
   my ($sql, $lookup);

   # Check to make sure we don't already have this in the database
   $lookup = $this->Resolve($name);
   return $lookup if (defined $lookup);

   $sql = Sql->new($this->{DBH});
   $name = $sql->Quote($name);
   $sql->Do(qq|insert into $this->{table} (Name, Ref, LastUsed) values 
               ($name, $id, '1970-01-01 00:00')|);

   if (lc($this->{table}) eq 'artistalias')
   {
       my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
       $engine->AddWordRefs($id,$name);
   }
}

sub Resolve
{
   my ($this, $name) = @_;
   my ($sql, $id, @row);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select("select ref, id from $this->{table} where name ilike ".
                    $sql->Quote($name)))
   {
       @row = $sql->NextRow();
       $id = $row[0];
       $sql->Finish;

        use MusicBrainz::Server::DeferredUpdate;
        MusicBrainz::Server::DeferredUpdate->Write(
            "Alias::UpdateLookupCount",
            $this->{table},
            $row[1],
        );
   }
   return $id;
}

sub Remove
{
   my ($this, $id) = @_;
   my $sql;

   if ($id)
   {
        $this->SetId($id);
        $this->LoadFromId;
   }

   my $parent = $this->Parent;

   $sql = Sql->new($this->{DBH});
   $sql->Do("delete from $this->{table} where id = " . $id);

   $parent->RebuildWordList;

   return 1;
}

sub GetList
{
    my ($this, $id) = @_;
    my $sql = Sql->new($this->{DBH});

    my $data = $sql->SelectListOfLists(
        "SELECT id, Name, TimesUsed, LastUsed, ModPending
        FROM $this->{table}
        WHERE ref = ?
        ORDER BY TimesUsed DESC",
        $id,
    );

    @$data;
}

# Load all the aliases for a given artist and return an array of references to alias
# objects. Returns undef if error occurs
sub LoadFull
{
   my ($this, $artist) = @_;
   my (@info, $query, $sql, @row, $alias);

   $sql = Sql->new($this->{DBH});
   $query = qq|select id, name, ref, lastused, timesused 
                 from $this->{table}
                where ref = $artist
             order by lower(name), name|;

   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
           $alias = Alias->new($this->{DBH});
           $alias->{table} = "artistalias";
           $alias->SetId($row[0]);
           $alias->SetName($row[1]);
           $alias->SetRowId($row[2]);
           $alias->SetLastUsed($row[3]);
           $alias->SetTimesUsed($row[4]);
           push @info, $alias;
       }
       $sql->Finish;
   
       return \@info;
   }

   return undef;
}

sub ParentClass
{
    my $this = shift;
    return "Artist" if lc($this->{table}) eq "artistalias";
    die "Don't understand Alias where table = $this->{table}";
}

sub Parent
{
    my $this = shift;
    my $parentclass = $this->ParentClass;
    my $parent = $parentclass->new($this->{DBH});
    $parent->SetId($this->GetRowId);
    $parent->LoadFromId
        or die "Couldn't load $parentclass #" . $this->GetRowId;
    $parent;
}

1;
# vi: set ts=4 sw=4 et :
