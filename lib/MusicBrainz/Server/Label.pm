package MusicBrainz::Server::Label;
use Moose;
extends 'TableBase';

use Carp qw( carp cluck croak );
use DBDefs;
use Encode qw( decode encode );
use LocaleSaver;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Validation qw( unaccent );
use POSIX qw(:locale_h);
use String::Similarity;

sub LinkEntityName { "label" }
sub entity_type { "label" }

use constant LABEL_TYPE_UNKNOWN                 => 0;
use constant LABEL_TYPE_DISTRIBUTOR             => 1;
use constant LABEL_TYPE_HOLDING                 => 2;
use constant LABEL_TYPE_PRODUCTION              => 3;
use constant LABEL_TYPE_ORIGINAL_PRODUCTION     => 4;
use constant LABEL_TYPE_BOOTLEG_PRODUCTION      => 5;
use constant LABEL_TYPE_REISSUE_PRODUCTION      => 6;
use constant LABEL_TYPE_PUBLISHER               => 7;

my %LabelTypeNames = (
   0 => [ 'Unknown', 0 ],
   1 => [ 'Distributor', 0 ],
   2 => [ 'Holding', 0 ],
   3 => [ 'Production', 0 ],
   4 => [ 'Original Production', 1 ],
   5 => [ 'Bootleg Production', 1 ],
   6 => [ 'Reissue Production', 1 ],
   7 => [ 'Publisher', 0 ],
);

sub GetLabelTypes
{
    my @types;
    for (my $id = 0; $id <= 7; $id++)
    {
        my $type = [$id, $LabelTypeNames{$id}->[0], undef, $LabelTypeNames{$id}->[1]];
        push @types, $type;
    }
    return \@types;
}

sub IsValidType
{
    my $type = shift;
    return (defined $type and $type ne "" and $type >= 0 and $type <= 7);
}

=head1 SLOTS

=head2 label_code

A code used to distinguish labels, originally for rights purposes.

=cut

has 'label_code' => (
    is => 'rw',
    init_arg => 'labelcode',
);

=head2 sort_name

The name of this label used for sorting

=cut

has 'sort_name' => (
    is => 'rw',
    init_arg => 'sortname'
);

=head2 country

The country this label operates in

=cut

has 'country' => (
    is => 'rw',
);

=head2 type

What type of label this is.

=cut

has 'type' => (
    is => 'rw',
    default => 0,
);

=head2 resolution

A comment assossciated with this label, usually used for disambiguation

=cut

has 'resolution' => (
    is => 'rw',
    default => ''
);

=head2 begin_date

The date this label was founded.

=cut

has 'begin_date' => (
    is => 'rw',
    init_arg => 'begindate'
);

=head2 end_date

The date this label dissolved.

=cut

has 'end_date' => (
    is => 'rw',
    init_arg => 'enddate'
);

=head1 METHODS

=head2 TEMPLATE HELPERS

=head3 country_name

Returns the name of the country assossciated with this label

=cut

sub country_name
{
    my $self = shift;

    unless (defined $self->{country_ref})
    {
        $self->{country_ref} = MusicBrainz::Server::Country->newFromId($self->dbh, $self->country);
    }
    
    return defined $self->{country_ref} ? $self->{country_ref}->name : '';
}

=head3 type_name

Returns a human readable string for the type of a label

=cut

sub type_name
{
    my $type = shift;
    $type = ref $type ? $type->type : $type;
    return $LabelTypeNames{$type}->[0];
}

=head2 has_complete_date_range

Returns true if the label has both a start and end date; false otherwise

=cut

sub has_complete_date_range
{
    my $self = shift;
    return $self->begin_date && $self->end_date;
}

sub begin_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->begin_date();
    return grep { $_ > 0 || $_ ne '00' } split(m/-/, $self->begin_date);
}

sub end_date_ymd
{
    my $self = shift;
    
    return ('', '', '') unless $self->end_date();
    return grep { $_ > 0 || $_ ne '00' } split(m/-/, $self->end_date);
}

sub _id_cache_key
{
    my ($class, $id) = @_;
    "label-id-" . int($id);
}

sub _mbid_cache_key
{
    my ($class, $mbid) = @_;
    "label-mbid-" . lc $mbid;
}

sub _invalidate_cache
{
    my $self = shift;
    MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
    MusicBrainz::Server::Cache->delete($self->_mbid_cache_key($self->mbid));
}

=head2 Insert

Insert a label into the DB and return the label id. Returns undef
on error. The name of this label must be set via the accesor
functions.

=cut

sub Insert
{
    my ($self, %opts) = @_;

    $self->{new_insert} = 0;

    # Check name
    my $name = $self->name
        or return;

    MusicBrainz::Server::Validation::TrimInPlace($name);
    $self->name($name);

    my $sql = Sql->new($self->dbh);

    if (!$self->resolution)
    {
        my $ar_list = $self->find_labels_by_name($name);
        my @dupes = grep { lc $_->name eq lc $name } @$ar_list;

        if (scalar @dupes) {
            return $dupes[0]->id;
        }
    }

    my $page = $self->CalculatePageIndex($self->sort_name);
    my $mbid = $self->CreateNewGlobalId;
    $self->mbid($mbid);

    $sql->Do(qq{
        INSERT INTO label
            (name, labelcode, gid, type, sortname, country, resolution,
             begindate, enddate, modpending, page)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?)
        },
        $self->name,
        $self->label_code || undef,
        $self->mbid,
        $self->type,
        $self->sort_name,
        $self->country || undef,
        $self->resolution || undef,
        $self->begin_date || undef,
        $self->end_date || undef,
        $page,
    );

    $self->id($sql->GetLastInsertId('Label'));
    $self->{new_insert} = 1;

    MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
    MusicBrainz::Server::Cache->delete($self->_mbid_cache_key($mbid));

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.
    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, 'label');
    $engine->AddWordRefs($self->id, $self->name);

    return $self->id;
}

=head2 Remove

Remove an label from the database. Set the id via the accessor function.

=cut

sub Remove
{
    my ($self) = @_;

    return unless defined $self->id;

    my $sql = Sql->new($self->dbh);

    # See if there are any release events that needs this label
    my $refcount = $sql->SelectSingleValue(
        "SELECT COUNT(*) FROM release WHERE label = ?",
        $self->id,
    );
    if ($refcount > 0)
    {
        print STDERR "Cannot remove label ". $self->id .
            ". $refcount release events still depend on it.\n";
        return;
    }

    # Remove relationships
    require MusicBrainz::Server::Link;
    my $link = MusicBrainz::Server::Link->new($self->dbh);
    $link->RemoveByLabel($self->id);

    # Remove tags
    require MusicBrainz::Server::Tag;
    my $tag = MusicBrainz::Server::Tag->new($self->dbh);
    $tag->RemoveLabels($self->id);

    # Remove references from label words table
    require SearchEngine;
    my $engine = SearchEngine->new($self->dbh, 'label');
    $engine->RemoveObjectRefs($self->id);

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->DeleteLabel($self->dbh, $self->id);

    $self->RemoveGlobalIdRedirect($self->id, &TableBase::TABLE_LABEL);

    $sql->Do("DELETE FROM labelalias WHERE ref = ?", $self->id);
    $sql->Do("DELETE FROM label WHERE id = ?", $self->id);
    $self->_invalidate_cache;

    return 1;
}

sub MergeInto
{
    my ($old, $new, $mod) = @_;
    my $sql = Sql->new($old->dbh);

    require UserSubscription;
    my $subs = UserSubscription->new($old->dbh);
    $subs->LabelBeingMerged($old, $mod);

    my $o = $old->id;
    my $n = $new->id;

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->MergeLabels($old->dbh, $o, $n);

    require MusicBrainz::Server::Link;
    my $link = MusicBrainz::Server::Link->new($sql->dbh);
    $link->MergeLabels($o, $n);

    require MusicBrainz::Server::Tag;
    my $tag = MusicBrainz::Server::Tag->new($sql->dbh);
    $tag->MergeLabels($o, $n);

    $sql->Do("UPDATE release           SET label = ? WHERE label = ?", $n, $o);
    $sql->Do("UPDATE moderation_closed SET rowid = ? WHERE tab = 'label' AND rowid = ?", $n, $o);
    $sql->Do("UPDATE moderation_open   SET rowid = ? WHERE tab = 'label' AND rowid = ?", $n, $o);
    $sql->Do("UPDATE labelalias        SET ref   = ? WHERE ref = ?", $n, $o);

    $old->SetGlobalIdRedirect($old->id, $old->mbid, $new->id, &TableBase::TABLE_LABEL);

    # Insert the old name as an alias for the new one
    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($old->dbh);
    $al->table("labelalias");
    $al->Insert($n, $old->name);

    $sql->Do("DELETE FROM label WHERE id = ?", $o);

    $old->_invalidate_cache;
    $new->_invalidate_cache;
}

sub Update
{
    my ($this, $new) = @_;

    my $name = $new->{LabelName};

    my $sql = Sql->new($this->dbh);

    my %update;
    $update{name} = $new->{LabelName} if exists $new->{LabelName};
    $update{type} = $new->{Type} if exists $new->{Type};
    $update{labelcode} = $new->{LabelCode} if exists $new->{LabelCode};
    $update{country} = $new->{Country} if exists $new->{Country};
    $update{sortname} = $new->{SortName} if exists $new->{SortName};
    $update{resolution} = $new->{Resolution} if exists $new->{Resolution};
    $update{begindate} = $new->{BeginDate} if exists $new->{BeginDate};
    $update{enddate} = $new->{EndDate} if exists $new->{EndDate};

    if (exists $update{'sortname'})
    {
        my $page = $this->CalculatePageIndex($update{'sortname'});
        $update{'page'} = $page;
    }

    # We map the following attributes to NULL
    $update{labelcode} = undef
        if exists $update{labelcode} and $update{labelcode} eq '';
    $update{country} = undef
        if exists $update{country} and $update{country} eq '';
    $update{resolution} = undef
        if exists $update{resolution} and $update{resolution} eq '';
    $update{begindate} = undef
        if exists $update{begindate} and $update{begindate} eq '';
    $update{enddate} = undef
        if exists $update{enddate} and $update{enddate} eq '';

    my $attrlist = join ', ', map { "$_ = ?" } sort keys %update;

    my @values = map { $update{$_} } sort keys %update;

    # there is nothing to change, exit.
    return 1 unless $attrlist;

    $sql->Do("UPDATE label SET $attrlist WHERE id = ?", @values, $this->id)
        or return 0;
    $this->_invalidate_cache;

    # Update the search engine
    $this->name($name) if exists $update{name};
    $this->RebuildWordList;

    return 1;
}

sub UpdateModPending
{
    my ($self, $adjust) = @_;

    my $id = $self->id
    or croak "Missing label ID in UpdateModPending";
    defined($adjust)
    or croak "Missing adjustment in UpdateModPending";

    my $sql = Sql->new($self->dbh);
    $sql->Do(
    "UPDATE label SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
    $adjust,
    $id,
    );

    $self->_invalidate_cache;
}


=head2 RebuildWorldList

The label name has changed, or an alias has been removed
(or possibly, in the future, been changed).  Rebuild the words for this
label.

=cut

sub RebuildWordList
{
    my ($this) = @_;

    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($this->dbh);
    $al->table("LabelAlias");
    my @aliases = $al->load_all($this->id);
    @aliases = map { $_->name } @aliases;

    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'label');
    $engine->AddWordRefs(
        $this->id,
        [ $this->name, @aliases ],
        1, # remove other words
        );
}

=head2 find_labels_by_name

Return a hash of hashes for labels that match the given label name

=cut

sub find_labels_by_name
{
    my ($this, $labelname) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($labelname) if defined $labelname;
    if (not defined $labelname or $labelname eq "")
    {
        carp "Missing labelname in find_labels_by_name";
        return [];
    }

    my $sql = Sql->new($this->dbh);
    my $labels;
    {
        # First, try exact match on name
        $labels = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, labelcode, type, sortname, country,
                    resolution, begindate, enddate
             FROM label
             WHERE name = ?",
            $labelname);
        last if scalar(@$labels);

        # Search using 'ilike' is expensive, so try the usual capitalisations
        # first using the index.
        # TODO a much better long-term solution would be to have a "searchname"
        # column on the table which is effectively "lc unac label.name", then
        # search on that.
        my $lc = lc decode "utf-8", $labelname;
        my $uc = uc $lc;
        (my $tc = $lc) =~ s/\b(\w)/uc $1/eg;
        (my $fwu = $lc) =~ s/\A(\S+)/uc $1/e;

        $labels = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, labelcode, type, sortname, country,
                    resolution, begindate, enddate
             FROM label WHERE name IN (?, ?, ?, ?)",
            encode("utf-8", $uc),
            encode("utf-8", $lc),
            encode("utf-8", $tc),
            encode("utf-8", $fwu));
        last if scalar(@$labels);

        # Next, try a full case-insensitive search
        $labels = $sql->SelectListOfHashes(
            "SELECT id, name, gid, modpending, labelcode, type, sortname, country,
                    resolution, begindate, enddate
             FROM label WHERE LOWER(name) = LOWER(?)",
             $labelname);
        last if scalar(@$labels);

        # If that failed, then try to find the artist by sortname
        $labels = $this->find_labels_by_sort_name($labelname)
            and return $labels;

        # If that failed too, then try the artist aliases
        require MusicBrainz::Server::Alias;
        my $alias = MusicBrainz::Server::Alias->new($this->dbh, "labelalias");
        if (my $label = $alias->Resolve($labelname))
        {
            $labels = $sql->SelectListOfHashes(
                "SELECT id, name, gid, modpending, sortname, country,
                        resolution, begindate, enddate, type
                 FROM label WHERE id = ?",
                $label);
        }
    }
    return [] if (!defined $labels || !scalar(@$labels));

    my @results;
    foreach my $row (@$labels)
    {
        my $ar = MusicBrainz::Server::Label->new($this->dbh, $row);
        $ar->id($row->{id});
        $ar->mbid($row->{gid});
        $ar->name($row->{name});
        $ar->type($row->{type});
        $ar->label_code($row->{labelcode});
        $ar->country($row->{country});
        $ar->sort_name($row->{sortname});
        $ar->has_mod_pending($row->{modpending});
        $ar->resolution($row->{resolution});
        $ar->begin_date($row->{begindate});
        $ar->end_date($row->{enddate});
        push @results, $ar;
    }
    return \@results;
}

=head2 find_labels_by_sort_name

Return a hash of hashes for artists that match the given artist's sortname

=cut

sub find_labels_by_sort_name
{
    my ($this, $sortname) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($sortname) if defined $sortname;
    if (not defined $sortname or $sortname eq "")
{
        carp "Missing sortname in find_labels_by_sort_name";
        return [];
}

    my $sql = Sql->new($this->dbh);

    my $labels = $sql->SelectListOfHashes(
        "SELECT id, name, gid, modpending, sortname, country,
                resolution, begindate, enddate, type, labelcode
         FROM label
         WHERE LOWER(sortname) = LOWER(?)",
         $sortname);
    scalar(@$labels) or return [];

    my @results;
    foreach my $row (@$labels)
{
        my $ar = MusicBrainz::Server::Label->new($this->dbh);
        $ar->id($row->{id});
        $ar->mbid($row->{gid});
        $ar->name($row->{name});
        $ar->sort_name($row->{sortname});
        $ar->label_code($row->{labelcode});
        $ar->country($row->{country});
        $ar->resolution($row->{resolution});
        $ar->begin_date($row->{begindate});
        $ar->end_date($row->{enddate});
        $ar->has_mod_pending($row->{modpending});
        $ar->type($row->{type});
        push @results, $ar;
}
    return \@results;
}

=head2 LoadFromId

Load an label record given an label id, or an MB Id
returns 1 on success, undef otherwise. Access the label info via the
accessor functions.

=cut

sub LoadFromId
{
    my $this = shift;
    my $id;

    if ($id = $this->id)
    {
        my $obj = $this->new_from_id($id)
            or return undef;
        %$this = %$obj;
        return 1;
    }
    elsif ($id = $this->mbid)
    {
        my $obj = $this->new_from_mbid($id)
            or return undef;
        %$this = %$obj;
        return 1;
    }
    else
    {
        cluck "MusicBrainz::Server::Label::LoadFromId is called with no ID / MBID\n";
        return undef;
    }
}

sub new_from_id
{
    my $this = shift;
    $this = $this->new(shift) if not ref $this;
    my $id = shift;

    my $key = $this->_id_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
        $$obj->dbh($this->dbh) if $$obj;
        return $$obj;
    }

    my $sql = Sql->new($this->dbh);

    $obj = $this->_new_from_row(
        $sql->SelectSingleRowHash(
            "SELECT * FROM label WHERE id = ?",
            $id)
        );

    $obj->{mbid} = delete $obj->{gid} if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_mbid_cache_key($obj->mbid), \$obj)
        if $obj;
    $obj->dbh($this->dbh) if $obj;

    return $obj;
}

sub new_from_mbid
{
    my $this = shift;
    $this = $this->new(shift) if not ref $this;
    my $id = shift;

    my $key = $this->_mbid_cache_key($id);
    my $obj = MusicBrainz::Server::Cache->get($key);

    if ($obj)
    {
        $$obj->dbh($this->dbh) if $$obj;
    return $$obj;
    }

    my $sql = Sql->new($this->dbh);

    $obj = $this->_new_from_row(
    $sql->SelectSingleRowHash(
        "SELECT * FROM label WHERE gid = ?",
            $id,
    ),
    );

    if (!$obj)
    {
        my $newid = $this->CheckGlobalIdRedirect($id, &TableBase::TABLE_LABEL);
        if ($newid)
        {
            $obj = $this->_new_from_row(
                $sql->SelectSingleRowHash("SELECT * FROM label WHERE id = ?", $newid)
            );
        }
    }

    $obj->{mbid} = delete $obj->{gid} if $obj;

    # We can't store DBH in the cache...
    delete $obj->{dbh} if $obj;
    MusicBrainz::Server::Cache->set($key, \$obj);
    MusicBrainz::Server::Cache->set($obj->_id_cache_key($obj->id), \$obj)
    if $obj;
    $obj->dbh($this->dbh) if $obj;

    return $obj;
}

=head2 label_browse_selection

Pull back a section of label names for the browse label display.
Given an index character ($ind), a page offset ($offset) 
it will return an array of references to an array
of labelid, sortname, modpending. The array is empty on error.

=cut

sub label_browse_selection
{
    my ($self, $ind, $offset, $limit) = @_;

    return unless length($ind) > 0;
    
    $limit ||= 50;
    
    my $sql = Sql->new($self->dbh);
    my ($page, $page_max) = $self->CalculatePageIndex($ind);

    $sql->Select(qq{
        SELECT id, gid, sortname, resolution
          FROM label
         WHERE page >= ? AND page <= ?
      ORDER BY LOWER(sortname)
        OFFSET ?
        },
        $page,
        $page_max,
        $offset
    ) or return (0, []);

    my $total_entries = $sql->Rows + $offset;

    my @rows;
    for (1 .. $limit)
    {
        my $row = $sql->NextRowHashRef
            or last;
        push @rows, MusicBrainz::Server::Label->new($self->dbh, $row);
    }

    $sql->Finish;
    return ($total_entries, \@rows);
}

=head2 releases

Retreive the set of albums by this label. Returns an array of 
references to Album objects. Refer to the Album object for details.
The returned array is empty on error.

=cut

sub releases
{
    my ($this) = @_;
    my $sql = Sql->new($this->dbh);
    my $query = qq/
        SELECT
            album.id,
            artist.gid AS artist,
            album.name,
            album.modpending,
            album.gid,
            attributes,
            language,
            script,
            releasedate,
            catno,
            tracks,
            discids,
            puids,
            artist.name as artistname,
            rating,
            rating_count
        FROM
            release, album, albummeta, artist
        WHERE
            release.album = album.id
            AND albummeta.id = album.id
            AND artist.id = album.artist
            AND release.label = ?
        /;
    my @albums;
    if ($sql->Select($query, $this->id))
    {
        while(my @row = $sql->NextRow)
        {
            require MusicBrainz::Server::Release;
            my $album = MusicBrainz::Server::Release->new($this->dbh);
            $album->id($row[0]);
            $album->artist($row[1]);
            $album->name($row[2]);
            $album->has_mod_pending($row[3]);
            $album->mbid($row[4]);
            $row[5] =~ s/^\{(.*)\}$/$1/;
            $album->{attrs} = $row[5];
            $album->language_id($row[6]);
            $album->script_id($row[7]);
            $album->{releasedate} = $row[8];
            $album->{catno}       = $row[9];
            $album->{trackcount}  = $row[10];
            $album->{discidcount} = $row[11];
            $album->{puidcount}   = $row[12] || 0;
            $album->{artistname}  = $row[13];
            $album->{rating}      = $row[14];
            $album->{rating_count}= $row[15];
            push @albums, $album;
        }
    }
    $sql->Finish;
    return @albums;
}

sub subscribers
{
    my $self = shift;
    require UserSubscription;
    return UserSubscription->GetSubscribersForLabel($self->{dbh}, $self->id);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
# eof Label.pm
