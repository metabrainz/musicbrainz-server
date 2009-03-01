package MusicBrainz::Server::Link;
use Moose;
extends 'TableBase';

use Carp qw( croak );
use MooseX::AttributeHelpers;

require MusicBrainz::Server::LinkEntity;
require MusicBrainz::Server::Attribute;
require MusicBrainz::Server::URL;
require MusicBrainz::Server::Artist;
require MusicBrainz::Server::Release;
require MusicBrainz::Server::Track;

=head1 ATTRIBUTES

=head2 table

The table storing information about this link

=cut

has 'table' => (
    isa => 'Str',
    is  => 'ro'
);

has 'links' => (
    isa => 'ArrayRef',
    is  => 'rw',
    trigger => sub {
        my ($self, $ids) = @_;

        croak "Wrong number of IDs passed to SetIDs"
    		unless @$ids == $self->number_of_links;

    	@$self{ $self->_get_link_fields } = @$ids;
    }
);

has 'types' => (
    isa => 'ArrayRef',
    is  => 'ro',
    metaclass => 'Collection::List',
    provides => {
        count => 'number_of_links',
    }
);

has 'link_type' => (
    isa => 'Int',
    is  => 'rw',
);

has 'begin_date' => (
    isa => 'Str',
    is  => 'rw',
    initarg => 'begindate',
);

has 'end_date' => (
    isa => 'Str',
    is  => 'rw',
    initarg => 'enddate',
);

sub begin_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->begin_date;
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->begin_date);
}

sub end_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->end_date;
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->end_date);
}

=head1 METHODS

=head2 newFromId

=cut

sub newFromId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $table WHERE id = ?",
		$id,
	);
	$self->_new_from_row($row);
}

=head2 newFromMBId

=cut

sub newFromMBId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $table WHERE mbid = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub _new_from_row
{
    my ($self, $dbh, $row) = @_;
    my $new = $self->SUPER::_new_from_row($dbh, $row);

    $new->{links} = $self->links;
    $new->{types} = $self->types;
    $new->{table} = $self->table;

    return $new;
}

sub BUILDARGS
{
    my $self = shift;
    my $dbh  = shift;;

    if ((scalar @_ == 1 && ref $_[0] eq 'HASH') || scalar @_ == 0)
    {
        # The user has called with a hash reference, so use
        # a normal Moose constructor
        my $args = shift || {};
        return {
            dbh => $dbh,
            %$args,
        };
    }
    else
    {
        # So far, links are always between two things.  This may change one day.
        my $types = shift;
        ref($types) eq "ARRAY" or die "$types must be an array reference";
	    scalar @$types == 2 or die "$types must have length 2";

        MusicBrainz::Server::LinkEntity->ValidateTypes($types)
	    	or die "$types contains invalid types";

        return {
            dbh   => $dbh,
            types => $types,
            table => "l_" . join "_", @$types,
        };
    }
}

sub _get_link_fields
{
    my $self = shift;
    map { "link$_" } (0 .. ($self->number_of_links - 1));
}

=head2 link_type

Get the MusicBrainz::Server::LinkType object associated with this link

=cut

sub link_type
{
	my $self = shift;
	my $l = MusicBrainz::Server::LinkType->new($self->dbh, $self->types);
	$l->newFromId($self->link_type);
}

=head2 entities

Get all the linked entities (as an array ref)

=cut

sub entities
{
	my $self = shift;
	return [ map { $self->entity($_) } (0 .. 1) ];
}

=head2 entity $index

Get a linked entities by index C<$index>

=cut

sub entity
{
	my ($self, $index) = @_;
	croak "No index passed" unless defined $index;
	croak "Bad index passed" unless $index >= 0 and $index < $self->number_of_links;

	return MusicBrainz::Server::LinkEntity->newFromTypeAndId(
		$self->dbh,
		$self->types->[$index],
		$self->{'link' . $index},
	);
}

################################################################################
# Data Retrieval
################################################################################

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

	my $sql = Sql->new($self->dbh);
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
			 my $attr = MusicBrainz::Server::Attribute->new( $self->{dbh}, [$link->{link0_type} , $link->{link1_type}]);
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
		$link->{begindate} ||= '';
		$link->{enddate}   ||= '';
	}

    return @links;
}

sub FindLinkedAlbums
{
	my ($self, $entitytype, $entityid) = @_;
	
	my $sql = Sql->new($self->dbh);

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
	my $sql = Sql->new($self->dbh);

	my $datewhere = "";

	my @links = @{ $self->links };
    my @args = ($self->link_type, @links);
    if ($self->begin_date =~ /\S/)
	{
		$datewhere .= " AND begindate = ?";
		push @args, $self->begin_date;
	}
    if ($self->end_date =~ /\S/)
	{
		$datewhere .= " AND enddate = ?";
		push @args, $self->end_date;
	}

    my $table = $self->table;
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $table WHERE link_type = ? AND link0 = ? AND link1 = ? $datewhere",
		@args
	);

    # If both entity types are the same, test the inverse as well.
	my @types = $self->types;
	if (!$row && $types[0] eq $types[1])
	{
	    my $table = $self->table;
		$row = $sql->SelectSingleRowHash(
			"SELECT * FROM $self->$table WHERE link_type = ? AND link1 = ? AND link0 = ? $datewhere",
			@args
		);
	}
	$row or return undef;

	$self->id($row->{'id'});
	$self->mbid($row->{'mbid'});
	$self->has_mod_pending($row->{'modpending'});

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
	     my $urlobj = MusicBrainz::Server::URL->new($self->dbh);

		 $urlobj->Insert($$entities[1]->{url}, $$entities[1]->{desc}) 
			 or return undef;

		 $$entities[1]->{obj} = $urlobj;
		 $$entities[1]->{id} = $urlobj->id;
	}

	# Make a $self which contains all of the desired properties
	$self = $self->new($self->dbh, $link_type->types);
	$self->link_type($link_type->id);
	$self->links([ map { $_->{id} } @$entities ]);
	$self->begin_date($begindate);
	$self->end_date($enddate);

    return undef
	    if ($self->Exists);

	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	$sql->Do(
		"INSERT INTO $table (link_type"
		. (join "", map { ", $_" } $self->_get_link_fields)
		. ", begindate, enddate) VALUES (?"
		. (", ?" x $self->number_of_links)
		. ", ?, ?)",
		$self->link_type,
		@{ $self->links },
		$begindate || undef,
		$enddate || undef,
	);

	$self->id($sql->GetLastInsertId($self->table));
	$self->has_mod_pending(0);

	$self;
}

sub Update
{
	my $self = shift;

	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	$sql->Do(
		"UPDATE $table SET link0 = ?, link1 = ?, begindate = ?, enddate = ?, link_type = ? where id = ?",
		$self->Links,
		$self->begin_date || undef,
		$self->end_date || undef,
		$self->GetLinkType,
		$self->id,
	) or return undef;

	return 1;
}

sub Delete
{
	my $self = shift;

	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	$sql->Do(
		"DELETE FROM $table WHERE id = ?",
		$self->id,
	);

    # If the latter entity is a URL, delete URL
    if ($self->{_types}->[1] eq 'url')
	{
	     my $urlobj = MusicBrainz::Server::URL->new($self->dbh);
		 $urlobj->id($self->{link1});
         $urlobj->Remove();
	}

	my $attr = MusicBrainz::Server::Attribute->new($self->dbh, $self->{_types});
	$attr = $attr->newFromLinkId($self->id());
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
	my $sql = Sql->new($self->dbh);

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
				my $attr = MusicBrainz::Server::Attribute->new($self->dbh, [$link0_type, $link1_type]);
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

	my $sql = Sql->new($self->dbh);
	foreach my $row (@tables)
	{
		my ($table, $type1, $type2, $link) = @$row;
		$self->table($table);
		$self->types([$type1, $type2]);
		my $rows = $sql->SelectListOfHashes("SELECT id, link0, link1 FROM $table WHERE $link = ?", $entityid);
		foreach my $row (@$rows)
		{
			$self->id($row->{id});
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
	my $a = join ",", @{ $link_type->types };
	my $b = join ",", map { $_->{type} } @{$entities};
	return if $a eq $b;
	local $Carp::CarpLevel = $Carp::CarpLevel + 1;
	croak "Entity types ($b) do not match link type ($a)";
}

# Used for stats
sub CountLinksByType
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	return $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM ".$self->Table
	);
}

1;
# eof Link.pm
