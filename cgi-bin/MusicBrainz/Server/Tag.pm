# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2005 Robert Kaye
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

package MusicBrainz::Server::Tag;

use base qw( TableBase );
use Carp;
use List::Util qw( min max sum );
use URI::Escape qw( uri_escape );
use MusicBrainz::Server::Validation qw( encode_entities );
use Encode qw( decode encode );

# Algorithm for updating tags
# update:
#  - parse tag string into tag list
#     - separate by comma, trim whitespace
#  - load existing tags for user/entity from raw tables into a hash

#  - for each tag in tag list:
#        is tag in existing tag list? 
#           yes, remove from existing tag list, continue
#        find tag string in tag table, if not found, add it
#        add tag assoc to raw tables
#        find tag assoc in aggregate tables. 
#        if not found
#            add it
#        else
#            increment count in aggregate table
#
#    for each tag remaining in existing tag list:
#        remove raw tag assoc
#        decrement aggregate tag
#        if aggregate tag count == 0: remove aggregate tag assoc.

sub Update
{
	my ($self, $input, $userid, $entity_type, $entity_id) = @_;

    my (@new_tags, @old_tags, $count);

	@new_tags = grep {
		# remove non-word characters
		$_ =~ s/[^\p{IsWord}-]+/ /sg;
		# combine multiple spaces into one
		$_ =~ s/\s+/ /sg;
		# remove leading and trailing whitespace
		$_ =~ s/^\s*(.*?)\s*$/$1/;
		$_ = encode "utf-8", $_;
		$_;
	} split ',', lc(decode "utf-8", $input);
	# make sure the list contains only unique tags
	@new_tags = keys %{{ map { $_ => 1 } @new_tags }};

    require MusicBrainz;
    my $maindb = Sql->new($self->{DBH});

    my $tags = MusicBrainz->new;
    $tags->Login(db => 'RAWDATA');
   	my $tagdb = Sql->new($tags->{DBH});   

    eval
    {
        $maindb->Begin();
        $tagdb->Begin() if ($maindb != $tagdb);

        my $assoc_table = $entity_type . '_tag';
        my $assoc_table_raw = $entity_type . '_tag_raw';

        # Load the existing raw tag ids for this entity
        
        my %old_tag_info;
        my @old_tags;
        my $old_tag_ids = $tagdb->SelectSingleColumnArray("SELECT tag
                                                             FROM $assoc_table_raw
                                                            WHERE $entity_type = ? 
                                                              AND moderator = ?", $entity_id, $userid);
        if (scalar(@$old_tag_ids))
        {
            # Load the corresponding tag strings from the main server
            #
            @old_tags = $maindb->Select("SELECT id, name
                                              FROM tag
                                             WHERE id in (" . join(',', @$old_tag_ids) . ")"); 
            # Create a lookup friendly hash from the old tags
            if (@old_tags)
            {
                while(my $row = $maindb->NextRowRef())
                {
                    $old_tag_info{$row->[1]} = $row->[0];
                }
                $maindb->Finish();
            }
        }

        # Now loop over the new tags
        foreach my $tag (@new_tags)
        {
            # if a new tag already exists, remove it from the old tag list and we're done for this tag
            if (exists $old_tag_info{$tag})
            {
                delete $old_tag_info{$tag};
                next;
            }

            # Lookup tag id for current tag, checking for UNICODE 
            my $tagid = eval
            {
                $maindb->SelectSingleValue("SELECT tag.id FROM tag WHERE tag.name = ?", $tag);
            };
            if ($@)
            {
                my $err = $@;
                next if $err =~ /unicode/i;
                die $err;
            }
            if (!defined $tagid)
            {
                $maindb->Do("INSERT into tag (name) values (?)", $tag);
                $tagid = $maindb->GetLastInsertId('tag');
            }

            # Add raw tag associations
            $tagdb->Do("INSERT into $assoc_table_raw ($entity_type, tag, moderator) values (?, ?, ?)", $entity_id, $tagid, $userid);

            # Look for the association in the aggregate tags
            $count = $maindb->SelectSingleValue("SELECT count 
                                                   FROM $assoc_table 
                                                  WHERE $entity_type = ? 
                                                    AND tag = ?", $entity_id, $tagid);

            # if not found, add it
            if (!$count)
            {
                $maindb->Do("INSERT INTO $assoc_table ($entity_type, tag, count) values (?, ?, 1)", $entity_id, $tagid);
            }
            else
            {
                # Otherwise increment the refcount
                $maindb->Do("UPDATE $assoc_table set count = count + 1 where $entity_type = ? AND tag = ?", $entity_id, $tagid);
            }

            # With this tag taken care of remove it from the list
            delete $old_tag_info{$tag};
        }

        # For any of the old tags that were not affected, remove them since the user doesn't seem to want them anymore
        foreach my $tag (keys %old_tag_info)
        {
            # Lookup tag id for current tag
            my $tagid = $maindb->SelectSingleValue("SELECT tag.id FROM tag WHERE tag.name = ?", $tag);
            die "Cannot load tag" if (!$tagid);

            # Remove the raw tag association
            $tagdb->Do("DELETE FROM $assoc_table_raw 
                              WHERE $entity_type = ? 
                                AND tag = ? 
                                AND moderator = ?", $entity_id, $tagid, $userid);

            # Decrement the count for this tag
            $count = $maindb->SelectSingleValue("SELECT count 
                                                   FROM $assoc_table 
                                                  WHERE $entity_type = ? 
                                                    AND tag = ?", $entity_id, $tagid);

            if (defined $count && $count > 1)
            {
                # Decrement the refcount
                $maindb->Do("UPDATE $assoc_table SET count = count - 1 WHERE $entity_type = ? AND tag = ?", $entity_id, $tagid);
            }
            else
            {
                # if count goes to zero, remove the association
                $maindb->Do("DELETE FROM $assoc_table
                              WHERE $entity_type = ? 
                                AND tag = ?", $entity_id, $tagid);
            }
        }
    };
    if ($@)
    {
        my $err = $@;
        eval { $maindb->Rollback(); };
        eval { $tagdb->Rollback(); };
        die $err;
    }
    else
    {
        $maindb->Commit();
        $tagdb->Commit();
        return 1;
    }
}

sub Merge
{
	my ($self, $entity_type, $old_entity_id, $new_entity_id) = @_;

	my $assoc_table = $entity_type . '_tag';
	my $assoc_table_raw = $entity_type . '_tag_raw';

    my $maindb = $Moderation::DBConnections{READWRITE};
    my $tagdb = $Moderation::DBConnections{RAWDATA};

    # Load the tag ids for both entities
    my $old_tag_ids = $maindb->SelectSingleColumnArray("
        SELECT tag
          FROM $assoc_table
         WHERE $entity_type = ?", $old_entity_id);

    my $new_tag_ids = $maindb->SelectSingleColumnArray("
        SELECT tag
          FROM $assoc_table
         WHERE $entity_type = ?", $new_entity_id);
    my %new_tag_ids = map { $_ => 1 } @$new_tag_ids;

    foreach my $tag_id (@$old_tag_ids)
    {
        # If both entities share the tag, move the individual raw tags
        if ($new_tag_ids{$tag_id})
        {
            my $count = 0;

            # Load the moderator ids for this tag and both entities
            # TODO: move this outside of this loop, to avoid multiple queries
            my $old_editor_ids = $tagdb->SelectSingleColumnArray("
                SELECT moderator
                  FROM $assoc_table_raw
                 WHERE $entity_type = ? AND tag = ?", $old_entity_id, $tag_id);

            my $new_editor_ids = $tagdb->SelectSingleColumnArray("
                SELECT moderator
                  FROM $assoc_table_raw
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $tag_id);
            my %new_editor_ids = map { $_ => 1 } @$new_editor_ids;

            foreach my $editor_id (@$old_editor_ids)
            {
                # If the raw tag doesn't exist for the target entity, move it
                if (!$new_editor_ids{$editor_id})
                {
                    $tagdb->Do("
                        UPDATE $assoc_table_raw
                           SET $entity_type = ?
                         WHERE $entity_type = ?
                           AND tag = ?
                           AND moderator = ?", $new_entity_id, $old_entity_id, $tag_id, $editor_id);
                    $count++;
                }
            }

            # Update the aggregated tag count for moved raw tags
            if ($count)
            {
                $maindb->Do("
                    UPDATE $assoc_table
                       SET count = count + ?
                     WHERE $entity_type = ? AND tag = ?", $count, $new_entity_id, $tag_id);
            }

        }
        # If the tag doesn't exist for the target entity, move it
        else
        {
            $maindb->Do("
                UPDATE $assoc_table
                   SET $entity_type = ?
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $old_entity_id, $tag_id);
            $tagdb->Do("
                UPDATE $assoc_table_raw
                   SET $entity_type = ?
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $old_entity_id, $tag_id);
        }
    }

    # Delete unused tags
    $maindb->Do("DELETE FROM $assoc_table WHERE $entity_type = ?", $old_entity_id);
    $tagdb->Do("DELETE FROM $assoc_table_raw WHERE $entity_type = ?", $old_entity_id);

    return 1;
}

sub MergeReleases
{
	my ($self, $oldid, $newid) = @_;
	$self->Merge("release", $oldid, $newid);
}

sub MergeTracks
{
	my ($self, $oldid, $newid) = @_;
	$self->Merge("track", $oldid, $newid);
}

sub MergeArtists
{
	my ($self, $oldid, $newid) = @_;
	$self->Merge("artist", $oldid, $newid);
}

sub MergeLabels
{
	my ($self, $oldid, $newid) = @_;
	$self->Merge("label", $oldid, $newid);
}

sub Remove
{
	my ($self, $entity_type, $id) = @_;

	my $assoc_table = $entity_type . '_tag';
	my $assoc_table_raw = $entity_type . '_tag_raw';

    my $maindb = $Moderation::DBConnections{READWRITE};
    my $tagdb = $Moderation::DBConnections{RAWDATA};

    # Delete unused tags
    $maindb->Do("DELETE FROM $assoc_table WHERE $entity_type = ?", $id);
    $tagdb->Do("DELETE FROM $assoc_table_raw WHERE $entity_type = ?", $id);

    return 1;
}

sub RemoveReleases
{
	my ($self, $id) = @_;
	$self->Remove("release", $id);
}

sub RemoveTracks
{
	my ($self, $id) = @_;
	$self->Remove("track", $id);
}

sub RemoveArtists
{
	my ($self, $id) = @_;
	$self->Remove("artist", $id);
}

sub RemoveLabels
{
	my ($self, $id) = @_;
	$self->Remove("label", $id);
}

sub GetTagsForEntity
{
	my ($self, $entity_type, $entity_id) = @_;

   	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = $entity_type . '_tag';
	my $rows = $sql->SelectListOfHashes("SELECT tag.id, tag.name, count
		                                   FROM tag, $assoc_table
		                                  WHERE tag.id = $assoc_table.tag 
                                            AND $assoc_table.$entity_type = ?", $entity_id);
	return $rows;
}

# Get a hash of { tag1 => count, tag2 => count } value from all available tags.
sub GetTagHash
{
	my ($self, $limit) = @_;

	my $sql = Sql->new($self->GetDBH());
	my $rows = $sql->SelectListOfLists("SELECT name, refcount AS count
		                                  FROM tag
		                              ORDER BY refcount DESC
		                                 LIMIT ?", $limit);

	my %tags = map { $_->[0] => $_->[1] } @$rows;
	return \%tags;
}

# Get a hash of { tag1 => weight, tag2 => weight } value of tags related to `$tag`.
sub GetRelatedTagHash
{
	my ($self, $tag, $limit) = @_;

	my $sql = Sql->new($self->GetDBH());
	my $rows = $sql->SelectListOfLists("
		SELECT
			t2.name, tr.weight
		FROM
			tag t1
			JOIN tag_relation tr ON t1.id = tr.tag1 OR t1.id = tr.tag2
			JOIN tag t2 ON t1.id != t2.id AND (t2.id = tr.tag1 OR t2.id = tr.tag2)
		WHERE
			t1.name = ?
		ORDER BY tr.weight DESC
		LIMIT ?", $tag, $limit);

	my %tags = map { $_->[0] => $_->[1] } @$rows;
	return \%tags;
}

# Get a hash of { tag1 => count, tag2 => count } value from user's tags.
sub GetRawTagHash
{
	my ($self, $moderator_id) = @_;

	my $maindb = Sql->new($self->GetDBH());

	my $tags = MusicBrainz->new;
    $tags->Login(db => 'RAWDATA');
	my $tagdb = Sql->new($tags->{DBH});

	my %counts;

	my @entity_types = ('artist', 'label', 'track', 'release');
	foreach my $entity_type (@entity_types) {
		my $assoc_table = $entity_type . '_tag_raw';
		my $rows = $tagdb->SelectListOfLists("SELECT tag, COUNT(*)
		                                        FROM $assoc_table
		                                       WHERE $assoc_table.moderator = ?
		                                       GROUP BY tag", $moderator_id);
		foreach my $row (@$rows) {
			$counts{$row->[0]} += $row->[1];
		}
	}
	
	my %result;
	return \%result if (scalar(%counts) == 0);

	my $rows = $maindb->SelectListOfLists("SELECT id, name FROM tag
	                                        WHERE id IN (" . join(",", keys(%counts)) . ")");
	%result = map { $_->[1] => $counts{$_->[0]} } @$rows;
	return \%result;
}

# Get a hash of { tag1 => count, tag2 => count } value from tags for the
# speficied entity.
sub GetTagHashForEntity
{
	my ($self, $entity_type, $entity_id, $limit) = @_;

	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = $entity_type . '_tag';
	my $rows = $sql->SelectListOfLists("SELECT tag.name, count
		                                  FROM tag, $assoc_table
		                                 WHERE tag.id = $assoc_table.tag 
		                                   AND $assoc_table.$entity_type = ?
		                              ORDER BY count DESC
		                                 LIMIT ?", $entity_id, $limit);

	my %tags = map { $_->[0] => $_->[1] } @$rows;
	return \%tags;
}

sub GetRawTagsForEntity
{
	my ($self, $entity_type, $entity_id, $moderator_id) = @_;

	my $maindb = Sql->new($self->GetDBH());

	my $tags = MusicBrainz->new;
    $tags->Login(db => 'RAWDATA');
	my $tagdb = Sql->new($tags->{DBH});   

	my $assoc_table = $entity_type . '_tag_raw';
	my $rows = $tagdb->SelectSingleColumnArray("SELECT DISTINCT tag
		                                     FROM $assoc_table
		                                    WHERE $assoc_table.$entity_type = ?
                                              AND $assoc_table.moderator = ?", $entity_id, $moderator_id);
    return [] if (scalar(@$rows) == 0);

	$rows = $maindb->SelectListOfHashes("SELECT tag.id, tag.name
  	                                       FROM tag
	                                      WHERE tag.id in (" . join(",", @$rows) . ")
                                       ORDER BY tag.name");
	return $rows;
}

sub GetEditorsForEntityAndTag
{
	my ($self, $entity_type, $entity_id, $tag) = @_;

	my $maindb = Sql->new($self->GetDBH());

	my $tags = MusicBrainz->new;
    $tags->Login(db => 'RAWDATA');
	my $tagdb = Sql->new($tags->{DBH});   

	my $tag_id = $maindb->SelectSingleValue("SELECT tag.id
  	                                           FROM tag
	                                          WHERE tag.name = ?", lc($tag));
    return undef if (!defined $tag_id);

	my $assoc_table = $entity_type . '_tag_raw';
	my $rows = $tagdb->SelectSingleColumnArray("SELECT moderator
                                                  FROM $assoc_table
		                                         WHERE $assoc_table.$entity_type = ?
                                                   AND $assoc_table.tag = ?", $entity_id, $tag_id);
    return [{}] if (scalar(@$rows) == 0);

	$rows = $maindb->SelectListOfHashes("SELECT moderator.id, moderator.name 
                                           FROM moderator 
                                      LEFT JOIN moderator_preference 
                                             ON moderator_preference.name='tags_public' 
                                            AND moderator_preference.moderator=moderator.id 
                                          WHERE moderator.id in (" . join(",", @$rows) . ")
                                            AND (moderator_preference.value IS NULL 
                                                 OR moderator_preference.value = '1')");
	return $rows;
}

sub GetEntitiesForTag
{
	my ($self, $entity_type, $tag, $limit, $offset) = @_;

   	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = $entity_type . '_tag';
	my $entity_table = $entity_type eq "release" ? "album" : $entity_type;
	
	$offset ||= 0;

	$sql->Select(<<EOF, $tag, $offset);
		SELECT	DISTINCT j.$entity_type AS id, e.name AS name, e.gid AS gid, j.count
		FROM	$entity_table e, $assoc_table j, tag t
		WHERE	t.name = ? AND j.tag = t.id AND e.id = j.$entity_type
		ORDER BY j.count DESC, name ASC
		OFFSET ?
EOF

	my @rows;
	while ($limit--)
	{
		my $row = $sql->NextRowHashRef or last;
		push @rows, $row;
	}

	my $total_rows = $sql->Rows;
	$sql->Finish;

	return (\@rows, $offset + $total_rows);
}

sub GetEntitiesForRawTag
{
	my ($self, $entity_type, $tag, $moderator_id, $limit, $offset) = @_;

	my $maindb = Sql->new($self->GetDBH());

	my $tags = MusicBrainz->new;
    $tags->Login(db => 'RAWDATA');
	my $tagdb = Sql->new($tags->{DBH});   

	# lookup tag ID by name
	my $tag_id = $maindb->SelectSingleValue(
		"SELECT id FROM tag WHERE name = ?", $tag);
    return [] if (!$tag_id);

	# select all entity IDs
	my $assoc_table = $entity_type . '_tag_raw';
	my $rows = $tagdb->SelectSingleColumnArray(
		"SELECT $entity_type FROM $assoc_table
		 WHERE tag = ? AND moderator = ?", $tag_id, $moderator_id);
    return [] if (scalar(@$rows) == 0);

	my $entity_table = $entity_type eq "release" ? "album" : $entity_type;
	
	$offset ||= 0;
	$maindb->Select("SELECT id, name, gid FROM $entity_table WHERE id IN (".join(",", @$rows).") ORDER BY name OFFSET ?", $offset);

	my @rows;
	while ($limit--)
	{
		my $row = $maindb->NextRowHashRef or last;
		push @rows, $row;
	}

	my $total_rows = $maindb->Rows;
	$maindb->Finish;

	return (\@rows, $offset + $total_rows);
}

sub GetModerator	{ $_[0]{'moderator'} }
sub SetModerator	{ $_[0]{'moderator'} = $_[1] }

sub GenerateTagCloud
{
	my ($self, $tags, $type, $minsize, $maxsize, $rawtagslist, $urlprefix) = @_;
	my ($key, $value, $tag, $sizedelta, @res, %mytags);

	my @counts = sort { $a <=> $b } values %$tags;
	my $ntags = scalar @counts;
	return "(no tags)" if !$ntags;

    %mytags = map { $_->{name} => $_->{id} } @{$rawtagslist} if ($rawtagslist);

	$urlprefix = '/show/tag/?' if !defined($urlprefix);

	my $min = $counts[0];
	my $max = $counts[$ntags - 1];
	my $med = $ntags % 2
		? $counts[(($ntags + 1) / 2) - 1]
		: ($counts[($ntags / 2) - 1] + $counts[$ntags / 2]) / 2;
	my $sum = sum(@counts);
	my $avg = $sum / $ntags;

	# Scale down tag clouds with less than 20 "raw" tags
	my $boldthreshold = 0.25;
	$maxsize = $minsize + ($maxsize - $minsize) * log(1 + min(1, ($max > 0 ? $max - 1 : 0) / 20) * 1.718281828);
	if ($maxsize - $minsize < 0.2) {
		$boldthreshold = 1;
	}

	$avg /= $max;
	$med /= $max;

	$max -= $min;
	if ($max == 0) {
		$max = $min;
		$min = 0;
	}

	my $power = 1 + ($avg > $med ? -(($avg - $med) ** 0.6) : ($med - $avg) ** 0.6);

	#push @res, "Counts: @counts<br />";
	#my @counts2 = map { int($min + $max * ((($_ - $min) / $max) ** $power) + 0.5) } @counts;
	#push @res, "Counts2: @counts2<br />";
	#push @res, "Power: $power<br />";
	#push @res, "Min: $min<br />";
	#push @res, "Max: $max<br />";
	#push @res, "Median: $med<br />";
	#push @res, "Average: $avg<br />";

    my $mine;
	$sizedelta = $maxsize - $minsize;
	foreach $key (sort keys %$tags) {
		$value = (($tags->{$key} - $min) / $max) ** $power;
        $mine = (exists $mytags{$key}) ? 'class="MyTag" ' : '';
		push @res, '<span style="font-size:' . int($minsize + $value * $sizedelta + 0.5) . 'px;' . ($value > $boldthreshold ? "font-weight:bold;" : "") . '">';
		$tag = encode_entities($key);
		$tag =~ s/\s+/&nbsp;/;
		push @res, '<a '.$mine.'href="' . $urlprefix . 'tag=' . uri_escape($key) . "&amp;show=$type\">".$tag.'</a></span> &nbsp; ';
	}
	return join "", @res;
}

1;
# eof Tag.pm
