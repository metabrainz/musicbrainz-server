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

package MusicBrainz::Server::Alias;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use DBDefs;
use Carp qw( carp croak );
use Errno qw( EEXIST );

sub new
{
    my ($class, $dbh, $table) = @_;
    my $self = $class->SUPER::new($dbh);
    $self->{table} = lc $table;
    $self;
}

# Artist specific accessor function. Others are inherted from TableBase
sub table
{
    my ($self, $new_table) = @_;

    if (defined $new_table) { $self->{table} = $new_table; }
    return $self->{table};
}

sub row_id
{
    my ($self, $new_row_id) = @_;

    if (defined $new_row_id) { $self->{rowid} = $new_row_id; }
    return $self->{rowid};
}

sub last_used
{
    my ($self, $new_last_used) = @_;

    if (defined $new_last_used) { $self->{lastused} = $new_last_used; }
    return $self->{lastused};
}

sub times_used
{
    my ($self, $new_count) = @_;

    if (defined $new_count) { $self->{timesused} = $new_count; }
    return $self->{timesused};
}

sub LoadFromId
{
    my ($this) = @_;
    my $sql = Sql->new($this->dbh);
   
    my $table = lc $this->table;
    my $row = $sql->SelectSingleRowArray(
        "SELECT id, name, ref, lastused, timesused
        FROM $table
        WHERE id = ?",
        $this->id,
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
	my ($this, $id, $name, $otherref, $allowdupe) = @_;

    my $sql = Sql->new($this->dbh);
    my $table = lc $this->table;
    $sql->Do("LOCK TABLE $table IN EXCLUSIVE MODE");

	if (!$allowdupe)
	{
		# Check to make sure we don't already have this in the database
		if (my $other = $this->newFromName($name))
		{
			# Note: this sub used to return the rowid of the existing row
			$$otherref = $other if $otherref;
			$! = EEXIST;
			return 0;
		}
	}

    $sql->Do(
        "INSERT INTO $table (name, ref, lastused)
            VALUES (?, ?, '1970-01-01 00:00')",
        $name,
        $id,
    );

    if ($table eq 'artistalias')
    {
        require SearchEngine;
        my $engine = SearchEngine->new($this->dbh, 'artist');
        $engine->AddWordRefs($id,$name);
    }
    elsif ($table eq 'labelalias')
    {
        require SearchEngine;
        my $engine = SearchEngine->new($this->dbh, 'label');
        $engine->AddWordRefs($id,$name);
    }

    1;
}

sub UpdateName
{
    my $self = shift;
    my $otherref = shift;

    $self->{table}
		or croak "Missing table in UpdateName";
	my $id = $self->id
		or croak "Missing alias ID in UpdateName";
	my $name = $self->name;
	defined($name) && $name ne ""
		or croak "Missing alias name in UpdateName";
	my $rowid = $self->row_id
		or croak "Missing row ID in UpdateName";

    MusicBrainz::Server::Validation::TrimInPlace($name);

	my $sql = Sql->new($self->dbh);
    my $table = lc $self->table;

    $sql->Do("LOCK TABLE $table IN EXCLUSIVE MODE");

    if (my $other = $self->newFromName($name))
    {
        if ($other->id != $self->id)
        {
            # Note: this sub used to return the rowid of the existing row
            $$otherref = $other if $otherref;
            $! = EEXIST;
            return 0;
        }
    }

	$sql->Do(
		"UPDATE $table SET name = ? WHERE id = ?",
		$name,
		$id,
	);

    if ($table eq "artistalias")
    {
        # Update the search engine
        require MusicBrainz::Server::Artist;
        my $artist = MusicBrainz::Server::Artist->new($self->dbh);
        $artist->id($rowid);
        $artist->LoadFromId;
        $artist->RebuildWordList;
    }

    1;
}

sub newFromName
{
    my $self = shift;
	$self = $self->new(shift, shift) if not ref $self;
    my $name = shift;

    MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
    if (not defined $name or $name eq "")
    {
        carp "Missing name in newFromName";
        return undef;
    }

    my $sql = Sql->new($self->dbh);

    my $row = $sql->SelectSingleRowHash(
        "SELECT * FROM $self->{table}
        WHERE LOWER(name) = LOWER(?)
        LIMIT 1",
        $name,
    ) or return undef;

    $row->{rowid} = delete $row->{'ref'};
    $row->{dbh} = $self->dbh;
    bless $row, ref($self);
}

sub Resolve
{
    my ($this, $name) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
    if (not defined $name or $name eq "")
    {
        carp "Missing name in Resolve";
        return undef;
    }

    my $sql = Sql->new($this->dbh);

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

    my $sql = Sql->new($this->dbh);
    $sql->Do("DELETE FROM $this->{table} WHERE id = ?", $this->id)
        or return undef;

    $parent->RebuildWordList;

    1;
}

sub UpdateLastUsedDate
{
    my ($self, $id, $timestr, $timesused) = @_;
    $timesused ||= 1;
    my $sql = Sql->new($self->dbh);

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
    my $sql = Sql->new($this->dbh);

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

   $sql = Sql->new($this->dbh);
   $query = qq|select id, name, ref, lastused, timesused
                 from $this->{table}
                where ref = $artist
             order by lower(name), name|;

   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
           require MusicBrainz::Server::Alias;
           $alias = MusicBrainz::Server::Alias->new($this->dbh);
           $alias->{table} = $this->{table};
           $alias->id($row[0]);
           $alias->name($row[1]);
           $alias->row_id($row[2]);
           $alias->last_used($row[3]);
           $alias->times_used($row[4]);
           push @info, $alias;
       }
       $sql->Finish;
   
       return \@info;
   }

   $sql->Finish;
   return undef;
}

sub ParentClass
{
    my $this = shift;
    return "MusicBrainz::Server::Artist" if lc($this->{table}) eq "artistalias";
    return "MusicBrainz::Server::Label" if lc($this->{table}) eq "labelalias";
    die "Don't understand Alias where table = $this->{table}";
}

sub Parent
{
    my $this = shift;
    my $parentclass = $this->ParentClass;
    eval "require $parentclass; 1" or die $@;
    my $parent = $parentclass->new($this->dbh);
    $parent->id($this->row_id);
    $parent->LoadFromId
        or die "Couldn't load $parentclass #" . $this->row_id;
    $parent;
}

1;
# vi: set ts=4 sw=4 et :
