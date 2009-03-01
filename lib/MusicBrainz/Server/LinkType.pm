package MusicBrainz::Server::LinkType;
use Moose;
extends 'TableBase';

require MusicBrainz::Server::LinkEntity;

=head1 PACKAGE METHODS

=head2 InsertDefaultRows

Ensure each link table has a "root" row

=cut

sub InsertDefaultRows
{
	use MusicBrainz::Server::Replication 'RT_SLAVE';
	return if &DBDefs::REPLICATION_TYPE == RT_SLAVE;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;

	require Sql;
	my $sql = Sql->new($mb->{dbh});
	$sql->Begin;

	my @e = MusicBrainz::Server::LinkEntity->Types;

	for my $left (@e)
	{
		for my $right (@e)
		{
			next if $right lt $left;
			my $table = "lt_${left}_${right}";

			$sql->SelectSingleValue("SELECT 1 FROM $table WHERE id = 0")
				or $sql->Do(
					"INSERT INTO $table (id, parent, name, linkphrase, rlinkphrase, description, attribute, mbid) VALUES (0, 0, 'ROOT', '', '', '', '', ?)",
					TableBase::CreateNewGlobalId(),
				);
		}
	}

	$sql->Commit;
}

=head1 ATTRIBUTES

=head2 table

The table in the database the represents data abut this link

=cut

has 'table' => (
    isa => 'Str',
    is  => 'ro',
);

=head2 parent

The ID of the links parent

=cut

has 'parent_id' => (
    isa => 'Int',
    is  => 'rw',
    initarg => 'parent',
);

=head2 types

The source and destination types of this link.

=cut

has 'types' => (
    isa => 'ArrayRef',
    is  => 'ro',
    metaclass => 'Collection::List',
    provides => {
        count => 'number_of_links',
    }
);

=head2 link_phrase

The phrase joining the source type to the destination type.

=cut

has 'link_phrase' => (
    isa => 'Str',
    is  => 'rw',
    init_arg => 'linkphrase'
);

=head2 reverse_link_phrase

The link phrase joining the destination type to the source type

=cut

has 'reverse_link_phrase' => (
    isa => 'Str',
    is  => 'rw',
    init_arg => 'rlinkphrase',
);

=head2 description

A description of this link type

=cut

has 'description' => (
    isa => 'Str',
    is  => 'rw'
);

=head2 attributes

Attributes set on this link type

=cut

has 'attributes' => (
    isa => 'ArrayRef',
    is  => 'rw',
);

=head2 short_link_phrase

A short phrase linking the source type to the destination type

=cut

has 'short_link_phrase' => (
    isa => 'Str',
    is  => 'rw',
    init_arg => 'shortlinkphrase',
);

has 'priority' => (
    is => 'rw'
);

has 'child_order' => (
    is => 'rw',
    init_arg => 'childorder',
);

=head1 METHODS

=head2 CONSTRUCTORS

=head3 newFromPackedTypes $dbh, $packed

Construct from types packed into a string. C<$dbh> is a database handle,
C<$packed> contains the types of the link, packed into a string separated with
'-'.

=cut

sub newFromPackedTypes
{
	my ($class, $dbh, $packed) = @_;
	defined($packed) or return undef;
	my @types = split /-/, $packed, -1;

	$class->new($dbh, \@types);
}

=head2 newFromId $id

Create a new link from a row ID, C<$id>.

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

=head2 newFromMBId $id

Create a new link from a MusicBrainz Identifier, C<$id>.

=cut

sub newFromMBId
{
	my ($self, $id) = @_;

	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $table WHERE mbid = ?",
		$self->table, $id,
	);

	$self->_new_from_row($row);
}

=head2 newFromParentId $parent_id

Create a list of LinkType's, from a single parent ID, c<$parent_id>.

=cut

sub newFromParentId
{
	my ($self, $parentid) = @_;

	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM $table WHERE parent = ? AND id != parent ORDER BY childorder, name",
		$parentid,
	);

	map { $self->_new_from_row($_) } @$rows;
}

sub newFromParentIdAndChildName
{
	my ($self, $parentid, $childname) = @_;
	my $sql = Sql->new($self->dbh);
	my $table = $self->table;
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $table WHERE parent = ? AND LOWER(name) = LOWER(?)",
		$parentid,
		$childname,
	);
	$self->_new_from_row($row);
}

sub BUILDARGS
{
    my $self = shift;
    my $dbh  = shift;;

    if (scalar @_ == 1 && ref $_[0] eq 'HASH')
    {
        # The user has called with a hash reference, so use
        # a normal Moose constructor
        my $args = shift;
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
            table => "lt_" . join "_", @$types,
        };
    }
}

sub _new_from_row
{
    my ($self, $dbh, $row) = @_;
    my $new = $self->SUPER::_new_from_row($dbh, $row);

    $new->{table} = $self->table;
    $new->{types} = $self->types;

    return $new;
}

=head2 parent

The parent of this link, as an object

=cut

sub parent
{
    my $self = shift;
    return $self->newFromId($self->parent_id);
}

=head2 children

Return a list children objects

=cut

sub children
{
    my $self = shift;
    return $self->newFromParentId($self->id);
}

=head2 pack_types $types

Pack C<$types> into a single string.

=cut

sub pack_types
{
	my ($self, $types) = @_;
	$types ||= $self->types;
	join "-", @$types;
}

=head2 root

Find the root node of this link type

=cut

sub root
{
    my $self = shift;
    return $self->newFromId(0) or die;
}

=head2 is_root

Check if this node is the root node

=cut

sub is_root { $_[0]->id == 0 }

=head2 path_from_root

Calculate the path from this node, to the root node

=cut

sub path_from_root
{
	my ($self, $root) = @_;
	my @path;

	for (;;)
	{
		unshift @path, $self;
		last if $self->IsRoot;
		last if $root and $self->id == $root->id;
		$self = $self->Parent;
	}

	@path;
}

=head2 named_child $child_name

Find a node, that is a child of this node and has a given name, C<$child_name>.

=cut

sub named_child
{
	my ($self, $childname) = @_;
	$self->newFromParentIdAndChildName($self->id, $childname);
}

################################################################################
# Insert, Delete
################################################################################

# Always call named_child first, to check that it doesn't already exist
sub AddChild
{
	my ($self, $childname, $linkphrase, $rlinkphrase, $description,
		$attribute, $childorder, $shortlinkphrase, $priority) = @_;
	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"INSERT INTO $self->{_table} (
			parent, name, linkphrase, rlinkphrase, description, attribute,
			mbid, childorder, shortlinkphrase, priority
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		$self->id,
		$childname,
		$linkphrase,
		$rlinkphrase,
		$description,
		$attribute,
		TableBase::CreateNewGlobalId(),
		$childorder,
		$shortlinkphrase,
		$priority,
	);
	$self->newFromId($sql->GetLastInsertId($self->{_table}));
}

sub InUse 
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	my $table = "l_" . join "_", @{$self->{_types}};

	my $value = $sql->SelectSingleValue(
		"select count(*) from $table where link_type = ?",
		$self->id,
	);
	return $value > 0;
}

sub Delete
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	# Here we trust that the caller has tested "InUse", and found it to be
	# false.  If not, this statement might fail (FK violation).
	$sql->Do(
		"DELETE FROM $self->{_table} WHERE id = ?",
		$self->id,
	);
}

sub Update
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE $self->{_table} SET parent = ?, childorder = ?, name = ?,
			linkphrase = ?, rlinkphrase = ?, description = ?,
			attribute = ?, shortlinkphrase = ?, priority = ? WHERE id = ?",
		$self->parent_id, 
		$self->child_order, 
		$self->name,
		$self->link_phrase,
		$self->reverse_link_phrase,
		$self->description,
		$self->attributes,
		$self->short_link_phrase,
		$self->priority,
		$self->id,
	);
}

=head1 LICENSE

MusicBrainz -- the open internet music database

Copyright (C) 2000 Robert Kaye

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

1;
