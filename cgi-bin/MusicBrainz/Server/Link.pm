#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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

use strict;

package MusicBrainz::Server::Link;

use Carp qw( croak );
use base qw( TableBase );
require MusicBrainz::Server::LinkEntity;
require MusicBrainz::Server::Attribute;
require MusicBrainz::Server::URL;
require MusicBrainz::Server::Artist;
require MusicBrainz::Server::Release;
require MusicBrainz::Server::Track;

################################################################################
# Bare Constructor
################################################################################

sub new
{
    my ($class, $dbh, $types) = @_;

    my $self = $class->SUPER::new($dbh);

	# So far, links are always between two things.  This may change one day.
    # if anything else other than two types are passed in, this object will
    # be an on-the-fly object (read: const object)
	if (defined $types && @$types == 2)
	{
		ref($types) eq "ARRAY" or return undef;

		MusicBrainz::Server::LinkEntity->ValidateTypes($types)
			or return undef;
		my @t = @$types;
		$self->{_types} = \@t;
		$self->{_table} = "l_" . join "_", @t;
    }

    $self;
}

################################################################################
# Properties
################################################################################

sub Table			{ $_[0]{_table} }

# Get/SetId implemented by TableBase
sub Links			{ wantarray ? @{ $_[0]{_links} } : $_[0]{_links} }
sub Types			{ wantarray ? @{ $_[0]{_types} } : $_[0]{_types} }
sub GetNumberOfLinks{ scalar @{ $_[0]{_types} } }
sub _GetLinkFields	{ map { "link$_" } (0 .. $_[0]->GetNumberOfLinks-1) }
sub GetLinkType		{ $_[0]{link_type} }
sub SetLinkType		{ $_[0]{link_type} = $_[1] }
# Get/SetModPending in TableBase

# Set all the link IDs at once
sub SetLinks
{
	my ($self, $ids) = @_;
	croak "Wrong number of IDs passed to SetIDs"
		unless @$ids == $self->GetNumberOfLinks;
	$self->{_links} = [ @$ids ];
	@$self{ $self->_GetLinkFields } = @$ids;
}

# Get the MusicBrainz::Server::LinkType object associated with this link
sub LinkType
{
	my $self = shift;
	my $l = MusicBrainz::Server::LinkType->new($self->{DBH}, $self->{_types});
	$l->newFromId($self->GetLinkType);
}

# Get the linked entities - all of them (as an array or array ref)
sub Entities
{
	my $self = shift;
	my @e;
	push @e, $self->Entity(0);
	push @e, $self->Entity(1);
	wantarray ? @e : \@e;
}

# Get the linked entities - one at a time
sub Entity
{
	my ($self, $index) = @_;
	croak "No index passed" unless defined $index;
	croak "Bad index passed" unless $index >= 0 and $index < $self->GetNumberOfLinks;

	return MusicBrainz::Server::LinkEntity->newFromTypeAndId(
		$self->{DBH},
		$self->{_types}->[$index],
		$self->{'link' . $index},
	);
}

sub GetBeginDate
{
   return ( defined $_[0]->{begindate} ) ? $_[0]->{begindate} : '';
}

sub GetBeginDateYMD
{
   my $self = shift;

   return ('', '', '') unless $self->GetBeginDate();
   return map { $_ == 0 ? '' : $_ } split(m/-/, $self->GetBeginDate);
}

sub SetBeginDate
{
   $_[0]->{begindate} = $_[1];
}

sub GetEndDate
{
   return ( defined $_[0]->{enddate} ) ? $_[0]->{enddate} : '';
}

sub GetEndDateYMD
{
   my $self = shift;

   return ('', '', '') unless $self->GetEndDate();
   return map { $_ == 0 ? '' : $_ } split(m/-/, $self->GetEndDate);
}

sub SetEndDate
{
   $_[0]->{enddate} = $_[1];
}

################################################################################
# Data Retrieval
################################################################################

sub _new_from_row
{
	my $this = shift;
	my $self = $this->SUPER::_new_from_row(@_)
		or return;

	while (my ($k, $v) = each %$this)
	{
		$self->{$k} = $v
			if substr($k, 0, 1) eq "_";
	}
	$self->{DBH} = $this->{DBH};

	my $n = scalar @{ $self->{_types} };
	$self->{_links} = [ map { $self->{"link$_"} } 0..$n-1 ];

	bless $self, ref($this) || $this;
}

sub newFromId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->{DBH});
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE id = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub newFromMBId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->{DBH});
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE mbid = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub FindLinkedEntities
{
    my $self = shift;
    $self = $self->new(shift) if not ref $self;
	my ($id, $type, %opts) = @_;

	my @entity_list;
	if (%opts && exists $opts{to_type})
	{
		my $t = $opts{to_type};
		@entity_list = (ref($t) eq "ARRAY" ? @$t : ($t));
	}
	else
	{
		@entity_list = MusicBrainz::Server::LinkEntity->Types;
	}

	my $sql = Sql->new($self->{DBH});
    my @links;

	foreach my $item (@entity_list)
	{
        my @entities = sort { $a->{type} cmp $b->{type} } ( { id => $id, type => lcfirst($type) }, { id => 0, type=> $item } );
		my $table = "l_" . join '_', map { $_->{type} } @entities;
		my $link_table = "lt_" . join '_', map { $_->{type} } @entities;
		my $namefield = ($entities[1]->{type} eq "url") ? "url" : "name";

		my $rows;
		my $e0_type = $entities[0]->{type};
		my $e1_type = $entities[1]->{type};

		if ($e0_type ne $e1_type)
		{
			# both entities are a different type
			my $link = $entities[0]->{id} ? "link0" : "link1";
			
			$rows = $sql->SelectListOfHashes(
				"SELECT " 
			  . "$e0_type.id AS link0_id, " 
			  . "'$e0_type' AS link0_type, " 
			  . "$e0_type.gid AS link0_mbid, "
			  . "$e0_type.name AS link0_name, "
			  . ($e0_type eq "artist" 
			  	  ? "$e0_type.sortname AS link0_sortname, "
				  . "$e0_type.resolution AS link0_resolution, "
				  : "")
			  . "$link_table.name AS link_name, "
			  . "$link_table.linkphrase AS link_phrase, "
			  . "$link_table.rlinkphrase AS rlink_phrase, "
			  . "$e1_type.id AS link1_id, " 
			  . "'$e1_type' AS link1_type, " 
			  . "$e1_type.gid AS link1_mbid,  "
			  . "$e1_type.$namefield AS link1_name, "
			  . ($e1_type eq "artist" 
			  	  ? "$e1_type.sortname AS link1_sortname, "
				  . "$e1_type.resolution AS link1_resolution, "
				  : "")
			  . "$table.begindate AS begindate, "
			  . "$table.enddate AS enddate, " 
			  . "$table.id AS link_id, " 
			  . "$table.modpending, "
			  . "$e0_type.modpending AS link0_modpending, " 
			  . "$e1_type.modpending AS link1_modpending " 
			  . "FROM "
			  . "$table, "
			  . "$link_table, " 
			  . "$e0_type, " 
			  . "$e1_type " 
			  . "WHERE $link = ? "
			  . "AND link0 = $e0_type.id "
			  . "AND link1 = $e1_type.id "
			  . "AND $link_table.id = $table.link_type",
				$id
			);
			push @links, @$rows;
		} 
		else
		{
			# both entities are the same type
			$rows = $sql->SelectListOfHashes(
				"SELECT "
			  . "'' AS link0_name, "
			  . "? AS link0_id, "
			  . "'$e0_type' AS link0_type, "
			  . "$link_table.name AS link_name, "
			  . "$link_table.linkphrase AS link_phrase, "
			  . "$link_table.rlinkphrase AS rlink_phrase, "
			  . "$e0_type.id AS link1_id, "
			  . "$e0_type.$namefield AS link1_name, "	  
			  . "'$e0_type' AS link1_type, "
			  . "$e0_type.gid as link1_mbid, "
			  . ($e0_type eq "artist" 
			  	  ? "$e0_type.sortname AS link1_sortname, "
				  . "$e0_type.resolution AS link1_resolution, "
				  : "")			  
			  . "$table.begindate AS begindate, "
			  . "$table.enddate AS enddate, "
			  . "$table.id AS link_id, "
			  . "$table.modpending, "
			  . "$e0_type.modpending AS link0_modpending, " 
			  . "$e0_type.modpending AS link1_modpending " 
			  . "FROM $table, $link_table, $e0_type "
			  . "WHERE link0 = ? "
			  . "AND link1 = $e0_type.id "
			  . "AND $link_table.id = $table.link_type",
				$id, 
				$id,
			);
			push @links, @$rows;

			$rows = $sql->SelectListOfHashes(
				"SELECT "
			  . "'' AS link1_name, "
			  . "? AS link1_id, "
			  . "'$e0_type' AS link1_type, "
			  . "$link_table.name AS link_name, "
			  . "$link_table.linkphrase AS link_phrase, "
			  . "$link_table.rlinkphrase AS rlink_phrase, "
			  . "$e0_type.id AS link0_id, "
			  . "$e0_type.$namefield AS link0_name, "
			  . "'$e0_type' AS link0_type, "
			  . "$e0_type.gid as link0_mbid, "
			  . ($e0_type eq "artist" 
			  	  ? "$e0_type.sortname AS link0_sortname, "
				  . "$e0_type.resolution AS link0_resolution, "
				  : "")			  
			  . "$table.begindate AS begindate, "
			  . "$table.enddate AS enddate, "
			  . "$table.id AS link_id, "
			  . "$table.modpending, "
			  . "$e0_type.modpending AS link0_modpending, " 
			  . "$e0_type.modpending AS link1_modpending " 
			  . "FROM $table, $link_table, $e0_type "
			  . "WHERE link1 = ? "
			  . "AND link0 = $e0_type.id "
			  . "AND $link_table.id = $table.link_type",
				$id, 
				$id,
			);
			push @links, @$rows;
		}
	}

	foreach my $link (@links)
	{
		if ($link->{link_phrase} =~ /\{.*?\}/)
		{
			 my $attr = MusicBrainz::Server::Attribute->new( $self->{DBH}, [$link->{link0_type} , $link->{link1_type}]);
			 if ($attr)
			 {
			     my $obj = $attr->newFromLinkId($link->{link_id});
				 if ($obj)
				 {
         			 ($link->{link_phrase}, $link->{rlink_phrase}) = $obj->ReplaceAttributes($link->{link_phrase}, $link->{rlink_phrase});

                     # save the link attrs for use with the web service
					 $link->{_attrs} = $obj;
				 }
			 }
		}
	}

    return @links;
}


sub FindLinkedAlbums
{
	my ($self, $entitytype, $entityid) = @_;
	
	my $sql = Sql->new($self->{DBH});

	my (@albums, $links);

	$links = $sql->SelectListOfHashes("
		SELECT
			album.id,
			album.gid,
			album.name,
			lt.name AS linkphrase,
			artist.id AS artist_id,
			artist.name AS artist_name,
			l.begindate,
			albummeta.firstreleasedate
		FROM
			album
			JOIN l_album_artist AS l ON l.link0 = album.id
			JOIN lt_album_artist AS lt ON lt.id = l.link_type
			JOIN artist ON album.artist = artist.id
			JOIN albummeta ON album.id = albummeta.id
		WHERE
			l.link1 = ?

		UNION ALL SELECT
			album.id,
			album.gid,
			album.name,
			lt.name AS linkphrase,
			artist.id AS artist_id,
			artist.name AS artist_name,
			l.begindate,
			albummeta.firstreleasedate
		FROM
			album
			JOIN albumjoin ON album.id = albumjoin.album
			JOIN l_artist_track AS l ON l.link1 = albumjoin.track
			JOIN lt_artist_track AS lt ON lt.id = l.link_type
			JOIN artist ON album.artist = artist.id
			JOIN albummeta ON album.id = albummeta.id
		WHERE
			l.link0 = ?
	", $entityid, $entityid);
	push @albums, @$links;
	
	return \@albums;
}


# Given a sufficiently populated $self object, find out whether such a link
# exists in the database.  If it does, fill in the remaining fields (id, etc)
sub Exists
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $datewhere = "";

	my @links = $self->Links;
    my @args = ($self->GetLinkType, @links);
    if ($self->GetBeginDate() =~ /\S/)
	{
		$datewhere .= " AND begindate = ?";
		push @args, $self->GetBeginDate();
	}
    if ($self->GetEndDate() =~ /\S/)
	{
		$datewhere .= " AND enddate = ?";
		push @args, $self->GetEndDate();
	}

	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE link_type = ? AND link0 = ? AND link1 = ? $datewhere",
		@args
	);

    # If both entity types are the same, test the inverse as well.
	my @types = $self->Types;
	if (!$row && $types[0] eq $types[1])
	{
		$row = $sql->SelectSingleRowHash(
			"SELECT * FROM $self->{_table} WHERE link_type = ? AND link1 = ? AND link0 = ? $datewhere",
			@args
		);
	}
	$row or return undef;

	$self->SetId($row->{'id'});
	$self->SetMBId($row->{'mbid'});
	$self->SetModPending($row->{'modpending'});

	1;
}

# Given a link type and a set of things entities, insert and return a link
# connecting them all together.  If the link already exists, return undef.
sub Insert
{
	my ($self, $link_type, $entities, $begindate, $enddate) = @_;
	_link_type_matches_entities($link_type, $entities);

    # If the latter entity is a URL, then insert the URL and fix up the entity data
	if ($$entities[1]->{type} eq 'url' and not $entities->[1]{'id'})
	{
	     my $urlobj = MusicBrainz::Server::URL->new($self->{DBH});
		 
		 $urlobj->Insert($$entities[1]->{url}, $$entities[1]->{desc}) 
			 or return undef;
		
		 $$entities[1]->{obj} = $urlobj;
		 $$entities[1]->{id} = $urlobj->GetId;
	}

	# Make a $self which contains all of the desired properties
	$self = $self->new($self->{DBH}, scalar($link_type->Types));
	$self->SetLinkType($link_type->GetId);
	$self->SetLinks([ map { $_->{id} } @$entities ]);
	$self->SetBeginDate($begindate);
	$self->SetEndDate($enddate);

    return undef
	    if ($self->Exists);

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"INSERT INTO $self->{_table} (link_type"
		. (join "", map { ", $_" } $self->_GetLinkFields)
		. ", begindate, enddate) VALUES (?"
		. (", ?" x $self->GetNumberOfLinks)
		. ", ?, ?)",
		$self->GetLinkType,
		$self->Links,
		$begindate || undef,
		$enddate || undef,
	);

	$self->SetId($sql->GetLastInsertId($self->{_table}));
	$self->SetModPending(0);

	$self;
}

sub Update
{
	my $self = shift;

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE $self->{_table} SET link0 = ?, link1 = ?, begindate = ?, enddate = ?, link_type = ? where id = ?",
		$self->Links,
		$self->GetBeginDate || undef,
		$self->GetEndDate || undef,
		$self->GetLinkType,
		$self->GetId,
	) or return undef;

	return 1;
}

sub Delete
{
	my $self = shift;

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM $self->{_table} WHERE id = ?",
		$self->GetId,
	);

    # If the latter entity is a URL, delete URL
    if ($self->{_types}->[1] eq 'url')
	{
	     my $urlobj = MusicBrainz::Server::URL->new($self->{DBH});
		 $urlobj->SetId($self->{link1});
         $urlobj->Remove();
	}

	my $attr = MusicBrainz::Server::Attribute->new($self->{DBH}, $self->{_types});
	$attr = $attr->newFromLinkId($self->GetId());
	$attr->Delete() if ($attr);

	return 1;
}

################################################################################
# Merging 
################################################################################

sub MergeReleases
{
	my ($self, $oldid, $newid) = @_;
	$self->_Merge($oldid, $newid, "album");
}

sub MergeTracks
{
	my ($self, $oldid, $newid) = @_;
	$self->_Merge($oldid, $newid, "track");
}

sub MergeArtists
{
	my ($self, $oldid, $newid) = @_;
	$self->_Merge($oldid, $newid, "artist");
}

sub MergeLabels
{
	my ($self, $oldid, $newid) = @_;
	$self->_Merge($oldid, $newid, "label");
}

sub _Merge
{
	my ($self, $oldid, $newid, $type) = @_;
	
	my @entity_list = MusicBrainz::Server::LinkEntity->Types;
	my $sql = Sql->new($self->{DBH});

	# First delete all relationships between both entities.
	my $table = "l_" . $type . "_" . $type;
	$sql->Do("DELETE FROM $table WHERE (link0 = ? AND link1 = ?)".
			 					  " OR (link0 = ? AND link1 = ?)",
								  $oldid, $newid,
								  $newid, $oldid);

	
	# Preprate list of AR tables
	my @list;
	foreach my $item (@entity_list) 
	{
		if ($type eq $item)
		{
			push @list, [$type, $item, "link0", "link1"];
			push @list, [$item, $type, "link1", "link0"];
		}
		elsif ($type le $item)
		{
			push @list, [$type, $item, "link0", "link1"];
		}
		else
		{
			push @list, [$item, $type, "link1", "link0"];
		}
	}
	
	# And now merge remaining relationships
	foreach my $item (@list) 
	{
		my @delete;
		my ($link0_type, $link1_type, $link0, $link1) = @$item;
		
		$table = "l_" . $link0_type . "_" . $link1_type;
	
		# Select all relationships connected to the source entity
		my $rows = $sql->SelectListOfHashes(
			"SELECT * FROM $table WHERE $link0 = ?", $oldid);

		foreach my $row (@$rows)
		{
			# Select count of the same relationships to the target entity 
			my $newlinkid = $sql->SelectSingleValue(
				"SELECT id FROM $table WHERE ".
				"$link0 = ? AND $link1 = ? AND ".
				"NOT (begindate IS DISTINCT FROM ?) AND ".
				"NOT (enddate IS DISTINCT FROM ?) AND ".
				"link_type = ? LIMIT 1",
				$newid,	$row->{$link1},
				$row->{begindate}, $row->{enddate},
				$row->{link_type});
			
			if (defined $newlinkid)
			{
				# Merge attributes
				my $attr = MusicBrainz::Server::Attribute->new($self->{DBH}, [$link0_type, $link1_type]);
				$attr->MergeLinks($row->{id}, $newlinkid);

				push @delete, $row->{id};
			}
			else
			{
				# Move relationship
				$sql->Do("UPDATE $table SET $link0 = ? WHERE id = ?", $newid, $row->{id});
			}
		}
		
		# Drop unused relationships
		$sql->Do("DELETE FROM $table WHERE id IN (" . (join ", ", @delete) . ")")
			if @delete;
	}
}

################################################################################
# Removing
################################################################################

sub RemoveByRelease
{
	my ($self, $entityid) = @_;
	$self->_Remove($entityid, "album");
}

sub RemoveByArtist
{
	my ($self, $entityid) = @_;
	$self->_Remove($entityid, "artist");
}

sub RemoveByLabel
{
	my ($self, $entityid) = @_;
	$self->_Remove($entityid, "label");
}

sub RemoveByTrack
{
	my ($self, $entityid) = @_;
	$self->_Remove($entityid, "track");
}

sub _Remove
{
	my ($self, $entityid, $type) = @_;

	my @tables;
	my @entity_list = MusicBrainz::Server::LinkEntity->Types;
	foreach my $item (@entity_list)
	{
		if ($type eq $item)
		{
			push @tables, [ "l_${type}_${type}", $type, $type, "link0" ];
			push @tables, [ "l_${type}_${type}", $type, $type, "link1" ];
		}
		elsif ($type le $item)
		{
			push @tables, [ "l_${type}_${item}", $type, $item, "link0" ];
		}
		else
		{
			push @tables, [ "l_${item}_${type}", $item, $type, "link1" ];
		}
	}

	my $sql = Sql->new($self->{DBH});
	foreach my $row (@tables)
	{
		my ($table, $type1, $type2, $link) = @$row;
		$self->{_table} = $table;
		$self->{_types} = [$type1, $type2];
		my $rows = $sql->SelectListOfHashes("SELECT id, link0, link1 FROM $table WHERE $link = ?", $entityid);
		foreach my $row (@$rows)
		{
			$self->SetId($row->{id});
			$self->{link0} = $row->{link0};
			$self->{link1} = $row->{link1};
			$self->Delete();
		}
	}
	$sql->Finish();
}

################################################################################

sub _link_type_matches_entities
{
	my ($link_type, $entities) = @_;
	my $a = join ",", $link_type->Types;
	my $b = join ",", map { $_->{type} } @{$entities};
	return if $a eq $b;
	local $Carp::CarpLevel = $Carp::CarpLevel + 1;
	croak "Entity types ($b) do not match link type ($a)";
}

# Used for stats
sub CountLinksByType
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});
	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM ".$self->Table
	);
}

1;
# eof Link.pm
