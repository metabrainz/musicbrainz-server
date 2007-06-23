#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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
#   $Id: Tag.pm 5597 2005-05-02 10:14:43Z matt $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Tag;

use base qw( TableBase );
use Carp;
use Data::Dumper;

# Manage tag.refcount via triggers
#    if refcount goes to 0, nuke tag

sub Update
{
	my ($self, $input, $userid, $entity_type, $entity_id) = @_;

    my (@new_tags, @old_tags, $count);

    #TODO: Make list of tags unique
    @new_tags = grep((s/^\s*(.*?)\s*$/$1/,$_), split ',', lc($input));

   	my $maindb = Sql->new($self->GetDBH()); 

    # TODO: Actually setup two separate DB handles properly
    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login();
   	my $tagdb = Sql->new($mb->{DBH});   

    eval
    {
        # TODO: Setup eval block
        $maindb->Begin();
#        $tagdb->Begin();

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

            # Lookup tag id for current tag
            my $tagid = $maindb->SelectSingleValue("SELECT tag.id FROM tag WHERE tag.name = ?", $tag);
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
#        eval { $tagdb->Rollback(); };
        die $err;
    }
    else
    {
        $maindb->Commit();
#        $tagdb->Commit();
        return 1;
    }
}

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


sub GetTagsForEntity
{
	my ($self, $entity_type, $entity_id) = @_;

   	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = $entity_type . '_tag';

	my $rows = $sql->SelectListOfHashes(<<EOF, $entity_id);
		SELECT		t.id AS id, t.name AS name, COUNT(a.*) AS num
		FROM		tag t, $assoc_table a
		WHERE		t.id = a.tag AND a.$entity_type = ?
		GROUP BY	t.id, t.name
		ORDER BY	t.name
EOF

	return $rows;
}

sub GetEntitiesForTag
{
	my ($self, $entity_type, $tag) = @_;

   	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = $entity_type . '_tag';

	my $rows = $sql->SelectListOfHashes(<<EOF, $tag);
		SELECT	DISTINCT j.$entity_type AS id, e.name AS name, e.gid AS gid
		FROM	$entity_type e, $assoc_table j, tag t
		WHERE	t.name = ? AND j.tag = t.id AND e.id = j.$entity_type;
EOF

	return $rows;
}

sub GetModerator	{ $_[0]{'moderator'} }
sub SetModerator	{ $_[0]{'moderator'} = $_[1] }

1;
# eof Tag.pm
