package MusicBrainz::Server::Alias;
use Moose;
extends 'TableBase';

use Carp qw( carp croak );
use DBDefs;
use Errno qw( EEXIST );
use UNIVERSAL::require;

=head1 SLOTS

=head2 table

Which alias table to use for lookups

=cut

has 'table' => (
    is => 'rw'
);

=head2 row_id

The row_id of the real entity this alias points to

=cut

has 'row_id' => (
    is => 'rw',
    init_arg => 'ref'
);

has 'last_used' => (
    is => 'rw',
    init_arg => 'lastused',
);

has 'times_used' => (
    is => 'rw',
    init_arg => 'timesused',
);

sub BUILDARGS {
    my ($self, $dbh, $table, @rest) = @_;
    
    my $hash = scalar @rest == 1 && ref $rest[0] eq 'HASH' ? $rest[0] : { @rest };;
    $hash->{dbh}   = $dbh;
    $hash->{table} = $table;
    
    return $hash;
}

sub LoadFromId
{
    my $self = shift;
    
    my $sql = Sql->new($self->dbh);
   
    my $table = lc $self->table;
    my $row = $sql->SelectSingleRowArray(
        "SELECT id, name, ref, lastused, timesused
           FROM $table
          WHERE id = ?",
        $self->id,
    ) or return undef;

    @$self{qw(
        id name row_id last_used times_used
    )} = @$row;

    return 1;
}

=head2

To insert a new alias, this function needs to be passed the alias id
and an alias name.

=cut

sub Insert
{
    my ($self, $id, $name, $otherref, $allowdupe) = @_;

    my $sql = Sql->new($self->dbh);
    my $table = lc $self->table;
    $sql->Do("LOCK TABLE $table IN EXCLUSIVE MODE");

    if (!$allowdupe)
    {
        # Check to make sure we don't already have this in the database
        if (my $other = $self->new_from_name($name))
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
    
    my ($search_table) = ($table =~ /(.*)alias/);

    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, $search_table);
    $engine->AddWordRefs($id, $name);

    return 1;
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

    if (my $other = $self->new_from_name($name))
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

sub new_from_name
{
    my $self = shift;
    $self = $self->new(shift, shift) if not ref $self;
    my $name = shift;

    MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
    if (not defined $name or $name eq "")
    {
        carp "Missing name in new_from_name";
        return undef;
    }

    my $table = lc $self->table;
    my $sql = Sql->new($self->dbh);

    my $row = $sql->SelectSingleRowHash(qq{
        SELECT *
          FROM $table
        WHERE LOWER(name) = LOWER(?)
        LIMIT 1
        },
        $name,
    ) or return undef;
    
    return $self->new($self->dbh, $self->table, $row);
}

sub Resolve
{
    my ($self, $name) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
    if (not defined $name or $name eq "")
    {
        carp "Missing name in Resolve";
        return undef;
    }

    my $sql = Sql->new($self->dbh);

    my $row = $sql->SelectSingleRowArray(
        "SELECT ref, id FROM $self->{table}
        WHERE LOWER(name) = LOWER(?)
        LIMIT 1",
        $name,
    ) or return undef;
    
    use MusicBrainz::Server::DeferredUpdate;
    MusicBrainz::Server::DeferredUpdate->Write(
        "Alias::UpdateLookupCount",
        $self->table,
        $row->[1],
    );

    $row->[0];
}

sub Remove
{
    my $self = shift;
    my $parent = $self->Parent;

    my $sql = Sql->new($self->dbh);
    $sql->Do("DELETE FROM $self->{table} WHERE id = ?", $self->id)
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

=head2 load_all

Load all the aliases for a given entity and return an array of references to alias
objects.

=cut

sub load_all
{
    my ($self, $id) = @_;

    my $table = lc $self->table;

    my $sql = Sql->new($self->dbh);
    my $rows = $sql->SelectListOfHashes(qq{
        SELECT id, name, ref, lastused, timesused
          FROM $table
         WHERE ref = ?
      ORDER BY LOWER(name), name
        },
        $id
    );
    $sql->Finish;
    
    return map { MusicBrainz::Server::Alias->new($self->dbh, $table, $_) } @$rows;
}

sub ParentClass
{
    my $self = shift;

    return "MusicBrainz::Server::Artist" if lc($self->{table}) eq "artistalias";
    return "MusicBrainz::Server::Label"  if lc($self->{table}) eq "labelalias";

    die "Don't understand Alias where table = $self->{table}";
}

sub Parent
{
    my $self = shift;
    
    my $class = $self->ParentClass;
    $class->require;
    
    my $parent = $class->new($self->dbh, id => $self->row_id);
    $parent->LoadFromId
        or die "Couldn't load $class #" . $self->row_id;

    return $parent;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
