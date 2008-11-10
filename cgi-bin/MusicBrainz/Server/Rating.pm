# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2007 Sharon Myrtle Paradesi
#   Copyright (C) 2008 Aurelien Mino
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

package MusicBrainz::Server::Rating;

use base qw( TableBase ); 
use Carp; 
use Data::Dumper;
use List::Util qw( min max sum );
use URI::Escape qw( uri_escape ); 
use MusicBrainz::Server::Validation qw( encode_entities ); 
use Encode qw( decode encode ); 

sub Update 
{ 
	my ($self, $entity_type, $entity_id, $userid, $new_rating) = @_;

	# Return values
	my ($rating_count, $rating);

	require MusicBrainz; 
	my $maindb = Sql->new($self->GetDBH()); 

	my $ratings = MusicBrainz->new; 
	$ratings->Login(db => 'RAWDATA'); 
	my $rawdb = Sql->new($ratings->{DBH});   

	eval 
	{ 
		$maindb->Begin(); 
		$rawdb->Begin() if ($maindb != $rawdb); 

		my $assoc_table = ($entity_type eq "release") ? "albummeta" : $entity_type . '_meta';  
		my $assoc_table_raw = $entity_type . '_rating_raw'; 

		# Check if user has already rated this entity
		my $whetherrated = $rawdb->SelectSingleValue("
				SELECT rating 
				FROM $assoc_table_raw
				WHERE $entity_type = ? AND editor = ?", $entity_id, $userid);

		if($whetherrated)
		{
			# Already rated - so update
			if($new_rating)
			{
				$rawdb->Do("UPDATE $assoc_table_raw SET rating = ? 
							WHERE $entity_type = ? AND editor = ?",
								$new_rating, $entity_id, $userid);
			}
			else
			{
				$rawdb->Do("DELETE FROM $assoc_table_raw 
					WHERE $entity_type = ? AND editor = ?", $entity_id, $userid);
			}
		}
		else
		{
			# Not rated - so insert raw rating values
			$rawdb->Do("INSERT into $assoc_table_raw ($entity_type, rating, editor) 
			        	 values (?, ?, ?)", $entity_id, $new_rating, $userid);
		}
			
		# Update the aggregate rating
		my $rating_sum;
		my $row = $rawdb->SelectSingleRowArray("SELECT count(rating), sum(rating) 
					FROM $assoc_table_raw
					WHERE $entity_type = ? GROUP BY $entity_type", $entity_id);

		($rating_count, $rating_sum) = ($row ? @$row : (undef, undef));

		$rating = ($rating_count ? $rating_sum/$rating_count : undef);

		$maindb->Do("UPDATE $assoc_table 
				SET rating_count = ?, rating = ? 
				WHERE id = ?", $rating_count, $rating, $entity_id);
	};

	if ($@)
	{
		my $err = $@;
		eval { $maindb->Rollback(); };
		eval { $rawdb->Rollback(); };
		die $err;
	}
	else
	{
		$maindb->Commit();
		$rawdb->Commit();
		return ($rating, $rating_count);
	}
}

sub Merge
{
	my ($self, $entity_type, $old_entity_id, $new_entity_id) = @_;

	my $assoc_table = ($entity_type eq "release") ? "albummeta" : $entity_type . '_meta';  
	my $assoc_table_raw = $entity_type . '_rating_raw';

	my $maindb = $Moderation::DBConnections{READWRITE};
	my $rawdb = $Moderation::DBConnections{RAWDATA};

	# Load the editors raw ratings for this rating and both entities
	my $old_editor_ids = $rawdb->SelectSingleColumnArray("
		SELECT editor
		FROM $assoc_table_raw
		WHERE $entity_type = ?", $old_entity_id);

	my $new_editor_ids = $rawdb->SelectSingleColumnArray("
		SELECT editor
		FROM $assoc_table_raw
		WHERE $entity_type = ?", $new_entity_id);
	my %new_editor_ids = map { $_ => 1 } @$new_editor_ids;

	foreach my $editor_id (@$old_editor_ids)
	{
		# If the raw rating doesn't exist for the target entity, move it
		if (!$new_editor_ids{$editor_id})
		{
			$rawdb->Do("
				UPDATE $assoc_table_raw
				SET $entity_type = ?
				WHERE $entity_type = ?
				AND editor = ?", $new_entity_id, $old_entity_id, $editor_id);
		}
	}

	# Delete unused ratings (only raw ones, triggers should handle deletion of ratings in main DB)
	$rawdb->Do("DELETE FROM $assoc_table_raw WHERE $entity_type = ?", $old_entity_id);

	# Update the aggregate rating
	my $row = $rawdb->SelectSingleRowArray("
		SELECT count(rating), sum(rating) 
		FROM $assoc_table_raw
		WHERE $entity_type = ? GROUP BY $entity_type", $new_entity_id);

	my ($rating_count, $rating_sum) = ($row ? @$row : (undef, undef));

	my $rating = ($rating_count ? $rating_sum/$rating_count : undef);

	$maindb->Do("UPDATE $assoc_table 
				SET rating_count = ?, rating = ? 
				WHERE id = ?", $rating_count, $rating, $new_entity_id);
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

	my $assoc_table_raw = $entity_type . '_rating_raw';
	my $rawdb = $Moderation::DBConnections{RAWDATA};

	# Delete unused raw ratings (aggregate ratings will be removed by triggers)
	$rawdb->Do("DELETE FROM $assoc_table_raw WHERE $entity_type = ?", $id);

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

sub GetRatingForEntity
{
	my ($self, $entity_type, $entity_id) = @_;

	my $sql = Sql->new($self->GetDBH());
	my $assoc_table = ($entity_type eq "release") ? "albummeta" : $entity_type . '_meta';  

	my $rating = $sql->SelectSingleRowHash("
		SELECT rating, rating_count
		FROM $assoc_table
		WHERE id = ?", $entity_id);
	return $rating;
}

sub GetUserRatingForEntity
{
	my ($self, $entity_type, $entity_id, $userid) = @_;
	my $rating;

	require MusicBrainz; 
	my $ratings = MusicBrainz->new; 
	$ratings->Login(db => 'RAWDATA'); 
	my $rawdb = Sql->new($ratings->{DBH});

	my $assoc_table_raw = $entity_type . '_rating_raw';  

	$rating = $rawdb->SelectSingleValue("SELECT rating
			FROM $assoc_table_raw
			WHERE $entity_type = ? AND editor = ?",
			$entity_id, $userid);
	return $rating;
}

sub LoadUserRatingForEntities
{
	my ($entity_type, $entities, $userid) = @_;

	require MusicBrainz; 
	my $ratings = MusicBrainz->new; 
	$ratings->Login(db => 'RAWDATA'); 
	my $rawdb = Sql->new($ratings->{DBH});

	my $assoc_table_raw = $entity_type . '_rating_raw';  

	my @entities_ids = map ($_->GetId, @$entities);

	my $user_ratings = $rawdb->SelectListOfLists("SELECT $entity_type, rating
			FROM $assoc_table_raw
			WHERE $entity_type IN (". join(', ', @entities_ids) .") 
				AND editor = ?", $userid);
	return undef if (scalar(@$user_ratings) == 0);

	my %user_ratings = map { $_->[0] => $_->[1] } @$user_ratings;

	foreach my $entity (@$entities)
	{
		$entity->{user_rating} = $user_ratings{$entity->GetId};
	}
}

sub CancelRating
{
	my ($self, $entity_type, $entity_id, $userid) = @_;
	$self->Update($entity_type, $entity_id, $userid, undef);
}

sub GetEntitiesRatingsForUser
{
	my ($self, $entity_type, $userid, $limit, $offset) = @_;

	my $maindb = Sql->new($self->GetDBH());

	my $ratings = MusicBrainz->new;
	$ratings->Login(db => 'RAWDATA');
	my $rawdb = Sql->new($ratings->{DBH});   

	# select all raw ratings for user
	my $assoc_table = $entity_type . '_rating_raw';
	my $raw_ratings = $rawdb->SelectListOfLists(
		"SELECT $entity_type, rating FROM $assoc_table
		 WHERE editor = ?", $userid);
	return [] if (scalar(@$raw_ratings) == 0);
	my %raw_ratings = map { $_->[0] => $_->[1] } @$raw_ratings;

	my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

	$offset ||= 0;
	$maindb->Select("SELECT id, name, gid FROM $entity_table 
						WHERE id IN (".join(",", keys %raw_ratings).") 
						ORDER BY name OFFSET ?", $offset);
	my @rows;
	while ($limit--)
	{
		my $row = $maindb->NextRowHashRef or last;
		$row->{rating} = $raw_ratings{ $row->{id} };
		push @rows, $row;
	}

	my $total_rows = $maindb->Rows;
	$maindb->Finish;

	return (\@rows, $offset + $total_rows);
}

1;
# eof Rating.pm
