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
{ our @ISA = qw( TableBase ) }

use strict;
use DBI;
use DBDefs;
use Carp qw( carp croak );

sub new
{
    my ($class, $dbh, $table) = @_;
    my $self = $class->SUPER::new($dbh);
    $self->{table} = lc $table;
    $self;
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

    # Check to make sure we don't already have this in the database
    my $lookup = $this->Resolve($name);
    return $lookup if (defined $lookup);

    my $sql = Sql->new($this->{DBH});
    $sql->Do(
        "INSERT INTO $this->{table} (name, ref, lastused)
            VALUES (?, ?, '1970-01-01 00:00')",
        $name,
        $id,
    );

   if (lc($this->{table}) eq 'artistalias')
   {
       require SearchEngine;
       my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
       $engine->AddWordRefs($id,$name);
   }
}

sub UpdateName
{
    my $self = shift;

    $self->{table}
		or croak "Missing alias ID in UpdateName";
	my $id = $self->GetId
		or croak "Missing alias ID in UpdateName";
	my $name = $self->GetName;
	defined($name) && $name ne ""
		or croak "Missing alias name in UpdateName";
	my $rowid = $self->GetRowId
		or croak "Missing row ID in UpdateName";

    MusicBrainz::TrimInPlace($name);

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE $self->{table} SET name = ? WHERE id = ?",
		$name,
		$id,
	);

    if (lc($self->{table}) eq "artistalias")
    {
        # Update the search engine
        my $artist = Artist->new($self->{DBH});
        $artist->SetId($rowid);
        $artist->LoadFromId;
        $artist->RebuildWordList;
    }
}

sub Resolve
{
    my ($this, $name) = @_;

    MusicBrainz::TrimInPlace($name) if defined $name;
    if (not defined $name or $name eq "")
    {
        carp "Missing name in Resolve";
        return undef;
    }

    my $sql = Sql->new($this->{DBH});

    my $row = $sql->SelectSingleRowArray(
        "SELECT ref, id FROM $this->{table}
        WHERE LOWER(name) = LOWER(?)
        LIMIT 1",
        $name,
    ) or return undef;
    
    use MusicBrainz::Server::DeferredUpdate;
    MusicBrainz::Server::DeferredUpdate->Write(
        "Alias::UpdateLookupCount",
        $this->{table},
        $row->[1],
    );

    $row->[0];
}

sub Remove
{
    my $this = shift;
    my $parent = $this->Parent;

    my $sql = Sql->new($this->{DBH});
    $sql->Do("DELETE FROM $this->{table} WHERE id = ?", $this->GetId)
        or return undef;

    $parent->RebuildWordList;

    1;
}

sub UpdateLastUsedDate
{
    my ($self, $id, $timestr, $timesused) = @_;
    $timesused ||= 1;
    my $sql = Sql->new($self->{DBH});

    $sql->Do("
        UPDATE $self->{table}
        SET timesused = timesused + ?,
            lastused = CASE
                WHEN ? > lastused THEN ?
                ELSE lastused
            END
        WHERE id = ?
        ",
        $timesused,
        $timestr, $timestr,
        $id,
    );
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
