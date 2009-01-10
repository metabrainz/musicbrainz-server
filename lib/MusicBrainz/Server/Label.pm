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

package MusicBrainz::Server::Label;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Carp qw( carp cluck croak );
use DBDefs;
use String::Similarity;
use MusicBrainz::Server::Validation qw( unaccent );
use MusicBrainz::Server::Cache;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode encode );

sub LinkEntityName { "label" }
sub entity_type { "label" }

use constant LABEL_TYPE_UNKNOWN					=> 0;
use constant LABEL_TYPE_DISTRIBUTOR				=> 1;
use constant LABEL_TYPE_HOLDING					=> 2;
use constant LABEL_TYPE_PRODUCTION				=> 3;
use constant LABEL_TYPE_ORIGINAL_PRODUCTION		=> 4;
use constant LABEL_TYPE_BOOTLEG_PRODUCTION		=> 5;
use constant LABEL_TYPE_REISSUE_PRODUCTION		=> 6;
use constant LABEL_TYPE_PUBLISHER		=> 7;

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

# Label specific accessor function. Others are inherted from TableBase 
sub label_code
{
    my ($self, $new_code) = @_;

    if (defined $new_code) { $self->{labelcode} = $new_code; }
    return $self->{labelcode};
}

sub sort_name
{
    my ($self, $new_sort) = @_;

    if (defined $new_sort) { $self->{sortname} = $new_sort; }
    return $self->{sortname};
}

sub country
{
    my ($self, $new_country) = @_;

    if (defined $new_country) { $self->{country} = $new_country; }
    return $self->{country};
}

sub country_name
{
	my $self = shift;

	unless (defined $self->{country_ref})
	{
		$self->{country_ref} = MusicBrainz::Server::Country->newFromId($self->dbh, $self->country);
	}
	
	return $self->{country_ref}->name;
}

sub type
{
    my ($self, $new_type) = @_;

    if (defined $new_type) { $self->{type} = $new_type; }
    return defined $self->{type} ? $self->{type} : 0;
}

sub type_name
{
	my $type = shift;
	$type = ref $type ? $type->type : $type;
	return $LabelTypeNames{$type}->[0];
}

sub _id_cache_key
{
    my ($class, $id) = @_;
    "label-id-" . int($id);
}

sub _GetMBIDCacheKey
{
    my ($class, $mbid) = @_;
    "label-mbid-" . lc $mbid;
}

sub InvalidateCache
{
    my $self = shift;
    MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
    MusicBrainz::Server::Cache->delete($self->_GetMBIDCacheKey($self->mbid));
}

sub begin_date_name
{
   return 'Begin Date';
}

sub end_date_name
{
   return 'End Date';
}

sub has_complete_date
{
    my $self = shift;
    return $self->begin_date && $self->end_date;
}

sub resolution
{
    my ($self, $new_resolution) = @_;

    if (defined $new_resolution) { $self->{resolution} = $new_resolution; }
    return defined $self->{resolution} ? $self->{resolution} : '';
}

sub begin_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{begindate} = $new_date; }
    return defined $self->{begindate} ? $self->{begindate} : '';
}

sub begin_date_ymd
{
    my $self = shift;

    return ('', '', '') unless $self->begin_date();
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->begin_date);
}

sub end_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{enddate} = $new_date; }
    return defined $self->{enddate} ? $self->{enddate} : '';
}

sub end_date_ymd
{
    my $self = shift;
    
    return ('', '', '') unless $self->end_date();
    return map { $_ == 0 ? '' : $_ } split(m/-/, $self->end_date);
}

# Insert an label into the DB and return the label id. Returns undef
# on error. The name of this label must be set via the accesor
# functions.
sub Insert
{
	my ($this, %opts) = @_;
	$this->{new_insert} = 0;

	# Check name
	defined(my $name = $this->name)
		or return undef;

	MusicBrainz::Server::Validation::TrimInPlace($name);
	$this->name($name);

	my $sql = Sql->new($this->dbh);
	my $label;

	if (!$this->resolution())
	{
		my $ar_list = $this->GetLabelsFromName($name);
		foreach my $ar (@$ar_list)
		{
			return $ar->id if ($ar->name() eq $name);
		}
		foreach my $ar (@$ar_list)
		{
			return $ar->id if (lc($ar->name()) eq lc($name));
		}
    }

    my $page = $this->CalculatePageIndex($this->{sortname});
    my $mbid = $this->CreateNewGlobalId;
    $this->mbid($mbid);

    $sql->Do(
	qq|INSERT INTO label
		    (name, labelcode, gid, type, sortname, country, resolution,
		     begindate, enddate, modpending, page)
	    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?)|,
	$this->name(),
	$this->label_code() || undef,
	$this->mbid(),
	$this->type(),
	$this->sort_name(),
	$this->country() || undef,
	$this->resolution() || undef,
	$this->begin_date() || undef,
	$this->end_date() || undef,
	$page,
    );


    $label = $sql->GetLastInsertId('Label');
    $this->{new_insert} = 1;
    $this->{id} = $label;

    MusicBrainz::Server::Cache->delete($this->_id_cache_key($label));
    MusicBrainz::Server::Cache->delete($this->_GetMBIDCacheKey($mbid));

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    require SearchEngine;
    my $engine = SearchEngine->new($this->dbh, 'label');
    $engine->AddWordRefs($label,$this->{name});

    return $label;
}

# Remove an label from the database. Set the id via the accessor function.
sub Remove
{
	my ($this) = @_;

	return if (!defined $this->id());

	my $sql = Sql->new($this->dbh);

	# See if there are any release events that needs this label
	my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM release WHERE label = ?",
		$this->id,
		);
	if ($refcount > 0)
	{
		print STDERR "Cannot remove label ". $this->id() .
    		". $refcount release events still depend on it.\n";
		return undef;
	}

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($this->dbh);
	$link->RemoveByLabel($this->id);

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
	$tag->RemoveLabels($this->id);

	# Remove references from label words table
	require SearchEngine;
	my $engine = SearchEngine->new($this->dbh, 'label');
	$engine->RemoveObjectRefs($this->id());

	require MusicBrainz::Server::Annotation;
	MusicBrainz::Server::Annotation->DeleteLabel($this->{dbh}, $this->id);

	$this->RemoveGlobalIdRedirect($this->id, &TableBase::TABLE_LABEL);

	$sql->Do("DELETE FROM labelalias WHERE ref = ?", $this->id);
	$sql->Do("DELETE FROM label WHERE id = ?", $this->id);
	$this->InvalidateCache;

	return 1;
}

sub MergeInto
{
	my ($old, $new, $mod) = @_;
	my $sql = Sql->new($old->{dbh});

    require UserSubscription;
    my $subs = UserSubscription->new($old->{dbh});
    $subs->LabelBeingMerged($old, $mod);

	my $o = $old->id;
	my $n = $new->id;

	require MusicBrainz::Server::Annotation;
	MusicBrainz::Server::Annotation->MergeLabels($old->{dbh}, $o, $n);

	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($sql->{dbh});
	$link->MergeLabels($o, $n);
	
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
	$tag->MergeLabels($o, $n);

	$sql->Do("UPDATE release           SET label = ? WHERE label = ?", $n, $o);
	$sql->Do("UPDATE moderation_closed SET rowid = ? WHERE tab = 'label' AND rowid = ?", $n, $o);
	$sql->Do("UPDATE moderation_open   SET rowid = ? WHERE tab = 'label' AND rowid = ?", $n, $o);
    $sql->Do("UPDATE labelalias        SET ref = ? WHERE ref = ?", $n, $o);
	
	$old->SetGlobalIdRedirect($old->id, $old->mbid, $new->id, &TableBase::TABLE_LABEL);

    # Insert the old name as an alias for the new one
    require MusicBrainz::Server::Alias;
    my $al = MusicBrainz::Server::Alias->new($old->{dbh});
    $al->table("labelalias");
    $al->Insert($n, $old->name);

	$sql->Do("DELETE FROM label WHERE id = ?", $o);
	$old->InvalidateCache;

    # Invalidate the new label as well
    $new->InvalidateCache;
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
	$this->InvalidateCache;

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

    $self->InvalidateCache;
}

# The label name has changed, or an alias has been removed
# (or possibly, in the future, been changed).  Rebuild the words for this
# label.

sub RebuildWordList
{
	my ($this) = @_;

	require MusicBrainz::Server::Alias;
	my $al = MusicBrainz::Server::Alias->new($this->dbh);
	$al->table("LabelAlias");
	my @aliases = $al->GetList($this->id);
	@aliases = map { $_->[1] } @aliases;

	require SearchEngine;
	my $engine = SearchEngine->new($this->dbh, 'label');
	$engine->AddWordRefs(
		$this->id,
		[ $this->name, @aliases ],
		1, # remove other words
		);
}

sub RebuildWordListForAll
{
    my $class = shift;

    my $mb_r = MusicBrainz->new; $mb_r->Login; my $sql_r = Sql->new($mb_r->{dbh});
    my $mb_w = MusicBrainz->new; $mb_w->Login; my $sql_w = Sql->new($mb_w->{dbh});

    $sql_r->Select("SELECT id FROM label");
    my $rows = $sql_r->Rows;

    my @notloaded;
    my @failed;
    my $noerrcount = 0;
    my $n = 0;
    $| = 1;

    use Time::HiRes qw( gettimeofday tv_interval );
    my $fProgress = 1;
    my $t1 = [gettimeofday];
    my $interval;

    my $p = sub {
    	my ($pre, $post) = @_;
	no integer;
	printf $pre."%9d %3d%% %9d".$post,
    	    $n, int(100 * $n / $rows),
	    $n / ($interval||1);
    };

    $p->("", "") if $fProgress;

    while ((my $id) = $sql_r->NextRow)
    {
	$sql_w->Begin;

	eval {
	    my $ar = MusicBrainz::Server::Label->new($mb_w->{dbh});
	    $ar->id($id);
	    if ($ar->LoadFromId)
	    {
		$ar->RebuildWordList;
	    } else {
		push @notloaded, $id;
	    }
	    $sql_w->Commit;
	};

	if (my $err = $@)
	{
	    eval { $sql_w->Rollback };
	    push @failed, $id;
	    warn "$err\n";
	} else {
	    ++$noerrcount;
	}

	++$n;
	unless ($n & 0x3F)
	{
    	    $interval = tv_interval($t1);
	    $p->("\r", "") if $fProgress;
	}
    }

    $sql_r->Finish;
    $interval = tv_interval($t1);
    $p->(($fProgress ? "\r" : ""), sprintf(" %.2f sec\n", $interval));

    printf "Total: %d  Errors: %d  Not loaded: %d  Success: %d\n",
	$n, 0+@failed, 0+@notloaded, $noerrcount-@notloaded;
}

# Return a hash of hashes for labels that match the given label name
sub GetLabelsFromName
{
	my ($this, $labelname) = @_;

	MusicBrainz::Server::Validation::TrimInPlace($labelname) if defined $labelname;
	if (not defined $labelname or $labelname eq "")
	{
		carp "Missing labelname in GetLabelsFromName";
		return [];
	}

	my $sql = Sql->new($this->dbh);
	my $labels;
    {
		# First, try exact match on name
		$labels = $sql->SelectListOfHashes(
	    	"SELECT	id, name, gid, modpending, labelcode, type, sortname, country,
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
		$labels = $this->GetLabelsFromSortname($labelname)
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
		my $ar = MusicBrainz::Server::Label->new($this->dbh);
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

# Return a hash of hashes for artists that match the given artist's sortname
sub GetLabelsFromSortname
{
	my ($this, $sortname) = @_;

	MusicBrainz::Server::Validation::TrimInPlace($sortname) if defined $sortname;
	if (not defined $sortname or $sortname eq "")
{
		carp "Missing sortname in GetLabelsFromSortname";
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

# Return a hash of hashes for artists that match the given LC
sub GetLabelsFromCode
{
	my ($this, $labelcode) = @_;

	if (!$labelcode)
	{
		carp "Missing labelcode in GetLabelsFromCode";
		return [];
	}

	my $sql = Sql->new($this->dbh);

	my $labels = $sql->SelectListOfHashes(
		"SELECT id, name, gid, modpending, sortname, country,
		        resolution, begindate, enddate, type, labelcode
		 FROM label
		 WHERE labelcode = ?",
		 $labelcode);
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

# Load an label record given an label id, or an MB Id
# returns 1 on success, undef otherwise. Access the label info via the
# accessor functions.
sub LoadFromId
{
	my $this = shift;
	my $id;

	if ($id = $this->id)
	{
		my $obj = $this->newFromId($id)
			or return undef;
		%$this = %$obj;
		return 1;
	}
	elsif ($id = $this->mbid)
	{
		my $obj = $this->newFromMBId($id)
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

sub newFromId
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
	MusicBrainz::Server::Cache->set($obj->_GetMBIDCacheKey($obj->mbid), \$obj)
		if $obj;
	$obj->dbh($this->dbh) if $obj;

	return $obj;
}

sub newFromMBId
{
    my $this = shift;
    $this = $this->new(shift) if not ref $this;
    my $id = shift;

    my $key = $this->_GetMBIDCacheKey($id);
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

# Pull back a section of label names for the browse label display.
# Given an index character ($ind), a page offset ($offset) 
# it will return an array of references to an array
# of labelid, sortname, modpending. The array is empty on error.
sub label_browse_selection
{
   my ($this, $ind, $offset) = @_;
   my ($query, @info, @row, $sql, $page, $page_max, $ind_max, $un, $max_labels); 

   return if length($ind) <= 0;

   $sql = Sql->new($this->dbh);

   use locale;
   # TODO set LC_COLLATE too?
   my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");
  
   ($page, $page_max) = $this->CalculatePageIndex($ind);
   $query = qq/select id, sortname, modpending
                    from Label 
                   where page >= $page and page <= $page_max/;
   $max_labels = 0;
   if ($sql->Select($query))
   {
       $max_labels = $sql->Rows();
       for(;@row = $sql->NextRow;)
       {
           my $temp = unaccent($row[1]);
	   $temp = lc decode("utf-8", $temp);

           # Remove all non alpha characters to sort cleaner
           $temp =~ tr/A-Za-z0-9 //cd;

           # Change space to 0 since perl has some FUNKY collate order
           $temp =~ tr/ /0/;
           push @info, [$row[0], $row[1], $row[2], $temp];
       }

       # This sort is necessary in order for us to get the right
       # ordering. Unfortunately its sorting a mainly sorted list
       # and it uses quicksort, which is BAD.
       @info = sort { $a->[3] cmp $b->[3] } @info;
       splice @info, 0, $offset;

       # Only return the three things we said we would
       splice(@$_, 3) for @info;
   }

   $sql->Finish;   
   return ($max_labels, @info);
}

# retreive the set of albums by this label. Returns an array of 
# references to Album objects. Refer to the Album object for details.
# The returned array is empty on error.
sub select_releases
{
	my ($this) = @_;
	my $sql = Sql->new($this->dbh);
	my $query = qq/
		SELECT
			album.id,
			artist,
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
			artist.name as artistname
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
			$album->{attrs} = [ split /,/, $row[5] ];
			$album->language_id($row[6]);
			$album->script_id($row[7]);
			$album->{releasedate} = $row[8];
			$album->{catno}       = $row[9];
			$album->{trackcount}  = $row[10];
			$album->{discidcount} = $row[11];
			$album->{puidcount}   = $row[12] || 0;
			$album->{artistname}  = $row[13];
			push @albums, $album;
		}
	}
	$sql->Finish;
	return @albums;
}

sub XML_URL
{
	my $this = shift;
	sprintf "http://%s/ws/1/label/%s?type=xml",
		&DBDefs::RDF_SERVER,
		$this->mbid,
	;
}

sub GetSubscribers
{
	my $self = shift;
	require UserSubscription;
	return UserSubscription->GetSubscribersForLabel($self->{dbh}, $self->id);
}

sub subscriber_count
{
	my $self = shift;
	return scalar $self->GetSubscribers;
}

sub InUse
{
	my ($self) = @_;
	my $sql = Sql->new($self->dbh);

	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM release WHERE label = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_album_label WHERE link1 = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_artist_label WHERE link1 = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_label_label WHERE link0 = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_label_label WHERE link0 = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_label_track WHERE link0 = ? LIMIT 1",
		$self->id,
		);
	return 1 if $sql->SelectSingleValue(
		"SELECT 1 FROM l_label_url WHERE link0 = ? LIMIT 1",
		$self->id,
		);
	return 0;
}

1;
# eof Label.pm
