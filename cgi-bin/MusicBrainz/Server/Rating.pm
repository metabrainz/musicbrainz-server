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
	my ($self, $new_rating, $userid, $entity_type, $entity_id) = @_;
 	my ($new_sum, $final_rating, $final_count, $res_count, $res_rating, @final, $temp, $output, $whetherrated, $temp_rating, $self_rated); 
	my ($mycount, $temporary);
 	
	my $maindb = Sql->new($self->GetDBH()); 
	# TODO: Actually setup two separate DB handles properly
	require MusicBrainz; 
	my $mb = MusicBrainz->new; 
	$mb->Login(); 
	my $ratingdb = $maindb;   
  	
	eval 
	{ 
		$self_rated=0;
		# TODO: Setup eval block
		$maindb->Begin(); 
		# $ratingdb->Begin(); 
 	
		my $assoc_table = $entity_type . '_rating';  
		my $assoc_table_raw = $entity_type . '_rating_raw'; 

		#check if user already rated
		#$whetherrated = $ratingdb->SelectSingleColumnArray("SELECT rating
 	       #                                                      	  	FROM $assoc_table_raw
 	       #                                                     	  	WHERE $entity_type = ?
 	       #                                                         	AND moderator = ?", $entity_id, $userid);

		#check if user already rated
		$whetherrated = $ratingdb->SelectSingleValue("SELECT rating
 	                                                             	  FROM $assoc_table_raw
 	                                                            	  WHERE $entity_type = ?
 	                                                                AND moderator = ?", $entity_id, $userid);
		#if(scalar(@$whetherrated))
		if($whetherrated)
		{
			#already rated - so update
			if($new_rating==$whetherrated)
			{
              		$ratingdb->Do("DELETE FROM $assoc_table_raw 
                                   		WHERE $entity_type = ? 
                                   		AND moderator = ?", $entity_id, $userid);
			}
			else
			{
			$ratingdb->Do("
				         UPDATE $assoc_table_raw 
				       	 set rating = $new_rating 
 				        	 where $entity_type = ? and moderator = ?", $entity_id, $userid);
			}
			#$maindb->Do("
			#	         UPDATE $assoc_table 
			#	       	 set count = count-1 
 			#	        	 where $entity_type = ?", $entity_id);
			
			$self_rated=1;
		}
		else
		{
			#not rated - so insert
			# Add raw rating values
			$ratingdb->Do("
		               	 INSERT into $assoc_table_raw ($entity_type, rating, moderator) 
			        	 values (?, ?, ?)", $entity_id, $new_rating, $userid);
		}
 	
		# Look for the enitity's rating in aggregate table
		$res_count = $maindb->SelectSingleValue("SELECT count
 	                                  				FROM $assoc_table
  	                                 			 	WHERE $entity_type = ?", $entity_id);

		$temp_rating = $maindb->SelectSingleValue("SELECT rating
 	                                  				FROM $assoc_table
  	                                 			 	WHERE $entity_type = ?", $entity_id);
           	# not yet rated by others
		if (!$temp_rating)
		{
			$final_rating=10*$new_rating;
			$final_count=1;
			$maindb->Do("
				       INSERT INTO $assoc_table ($entity_type, rating, count) 
				      values (?, ?, ?)", $entity_id, $final_rating, $final_count);
		}
		else #already rated by others
		{
			#if($self_rated) 
			#{
			#	#only current user had rated last.
			#	$final_rating=10*$new_rating;
			#	$maindb->Do("
			#       		UPDATE $assoc_table 
			#       		set rating = $final_rating 
			#        		where $entity_type = ?", $entity_id);
			#}
			#else
			#{
				#other users had rated too.
				#$res_rating = $maindb->SelectSingleValue("SELECT rating
 	                    #              					FROM $assoc_table
  	                    #             			 		WHERE $entity_type = ?", $entity_id);
				#$new_sum=$res_rating+(10*$new_rating);
				#$final_count=$res_count+1;
				#$final_rating=$new_sum/$final_count;
				#$maindb->Do("
				#        	UPDATE $assoc_table 
				#       	set count = count + 1, rating = $final_rating 
 				#        	where $entity_type = ?", $entity_id);

				my $array_rated = $ratingdb->SelectSingleColumnArray("SELECT rating
 	                                                             	  		  FROM $assoc_table_raw
 	                                                            	  		  WHERE $entity_type = ?", $entity_id);

				$mycount=scalar(@$array_rated);
				if($mycount)
				{
				$temporary=0;
				foreach (@$array_rated)
				{
					$temporary = $temporary + $_;
				}

				$new_sum=10*$temporary;
				$final_count=$mycount;
				$final_rating=$new_sum/$final_count;
				$maindb->Do("
				        	UPDATE $assoc_table 
				       	set count = $final_count, rating = $final_rating 
 				       	where $entity_type = ?", $entity_id);
				}
				else
				{

              		$maindb->Do("DELETE FROM $assoc_table 
                                   		WHERE $entity_type = ?", $entity_id);
				}

				
				

				
			#}
		}
	$output=$final_rating/10;
	};

	if ($@)
	{
		# TODO: Setup eval block
  	       my $err = $@;
  	       eval { $maindb->Rollback(); };
  	     #  eval { $ratingdb->Rollback(); };
 	       die $err;
	}
	else
	{
		$maindb->Commit();
  	    #   $ratingdb->Commit();
 	       return 1;
	}
	return $output;
}


#sub GetEntitiesForRating
#{
# 		my ($self, $entity_type, $rating, $limit) = @_;
# 
# 		my $sql = Sql->new($self->GetDBH());
# 		my $assoc_table = $entity_type . '_rating';
# 		my $entity_table = $entity_type eq "release" ? "album" : $entity_type;
# 
# 		my $rows = $sql->SelectListOfHashes(<<EOF, $rating, $limit);
# 		SELECT	DISTINCT j.$entity_type AS id, e.name AS name, e.gid AS gid, j.count
# 		FROM	$entity_table e, $assoc_table j
# 		WHERE	j.rating = ? AND e.id = j.$entity_type
# 		LIMIT ?
# 		EOF
# 
# 		return $rows;
#}

sub GetModerator	{ $_[0]{'moderator'} }

sub SetModerator	{ $_[0]{'moderator'} = $_[1] }

sub GenerateRatings
{
		my ($self, $entity_type, $entity_id) = @_;
		my ($temp, $temp1);

  		my $sql = Sql->new($self->GetDBH());
  		my $assoc_table = $entity_type . '_rating';
  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

		$temp = $sql->SelectSingleValue("SELECT rating
 	                                  		FROM $assoc_table
  	                                 		WHERE $entity_type = ?", $entity_id);
		$temp1=$temp/10;
  
  		return $temp1;
}


sub GenerateNewRatings
{
		my ($self, $entity_type, $entity_id) = @_;
		my ($temp, $temp1, $temp2, @answer, $myrating, $mycount);

#  		my $sql = Sql->new($self->GetDBH());
#  		my $assoc_table = $entity_type . '_rating';
#  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;
#
 		my $maindb = Sql->new($self->GetDBH()); 
 		# TODO: Actually setup two separate DB handles properly
 		require MusicBrainz; 
 		my $mb = MusicBrainz->new; 
 		$mb->Login(); 
 		my $ratingdb = $maindb;  
 
#  		my $sql = Sql->new($self->GetDBH());
   		my $assoc_table_raw = $entity_type . '_rating_raw';
#  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

		my $ratingvalues = $ratingdb->SelectSingleColumnArray("SELECT rating
 	                                                             	    FROM $assoc_table_raw
 	                                                            	    WHERE $entity_type = ?", $entity_id);
		$mycount=scalar(@$ratingvalues);

 	       if ($mycount)
 	       {
			$temp=0;
			foreach (@$ratingvalues)
			{
				$temp=$temp+$_;
			}
			$myrating=$temp/$mycount;
 	       }
 	       else
		{
			$myrating=0;	
		}


#		$temp = $sql->SelectSingleValue("SELECT rating
# 	                                  		FROM $assoc_table
#  	                                 		WHERE $entity_type = ?", $entity_id);
#		$temp1=$temp/10;
#
#		$temp2 = $sql->SelectSingleValue("SELECT count
# 	                                  		FROM $assoc_table
#  	                                 		WHERE $entity_type = ?", $entity_id);
#
 		@answer = ($myrating, $mycount);
   
  		return @answer;
}

sub GenerateUserRatings
{
		my ($self, $userid, $entity_type, $entity_id) = @_;
		my ($temp, $mycount, $myrating);

		my $maindb = Sql->new($self->GetDBH()); 
		# TODO: Actually setup two separate DB handles properly
		require MusicBrainz; 
		my $mb = MusicBrainz->new; 
		$mb->Login(); 
		my $ratingdb = $maindb;  

#  		my $sql = Sql->new($self->GetDBH());
   		my $assoc_table_raw = $entity_type . '_rating_raw';
#  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

		my $ratingvalues = $ratingdb->SelectSingleColumnArray("SELECT rating
 	                                                             	    FROM $assoc_table_raw
 	                                                            	    WHERE $entity_type = ?
 	                                                                  AND moderator = ?", $entity_id, $userid);
		$mycount=scalar(@$ratingvalues);

 	       if ($mycount)
 	       {
			$temp=0;
			foreach (@$ratingvalues)
			{
				$temp=$temp+$_;
			}
			$myrating=$temp/$mycount;
 	       }
 	       else
		{
			$myrating=0;	
		}
   
   		return $myrating;
}

sub CancelRating
{
		my ($self, $userid, $entity_type, $entity_id) = @_;
		my ($temp, $mycount, $myrating);

		my $maindb = Sql->new($self->GetDBH()); 
		# TODO: Actually setup two separate DB handles properly
		require MusicBrainz; 
		my $mb = MusicBrainz->new; 
		$mb->Login(); 
		my $ratingdb = $maindb;  

    eval
    {
        # TODO: Setup eval block
        $maindb->Begin();
#        $ratingdb->Begin();


#  		my $sql = Sql->new($self->GetDBH());
   		my $assoc_table_raw = $entity_type . '_rating_raw';
#  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

              $ratingdb->Do("DELETE FROM $assoc_table_raw 
                                   WHERE $entity_type = ? 
                                   AND moderator = ?", $entity_id, $userid);
    };
    if ($@)
    {
        my $err = $@;
        eval { $maindb->Rollback(); };
#        eval { $ratingdb->Rollback(); };
        die $err;
    }
    else
    {
        $maindb->Commit();
#        $ratingdb->Commit();
        return 1;
    }
}




sub VerifyRated
{
 		my ($self, $userid, $entity_type, $entity_id) = @_;
 		my ($countrating);

		my $maindb = Sql->new($self->GetDBH()); 
		# TODO: Actually setup two separate DB handles properly
		require MusicBrainz; 
		my $mb = MusicBrainz->new; 
		$mb->Login(); 
		my $ratingdb = $maindb;  

#  		my $sql = Sql->new($self->GetDBH());
   		my $assoc_table_raw = $entity_type . '_rating_raw';
#  		#my $entity_table = $entity_type eq "release" ? "album" : $entity_type;

		my $ratingvalues = $ratingdb->SelectSingleColumnArray("SELECT rating
 	                                                             	    FROM $assoc_table_raw
 	                                                            	    WHERE $entity_type = ?
 	                                                                  AND moderator = ?", $entity_id, $userid);

		$countrating=scalar(@$ratingvalues);
   
   		return $countrating;
}

1;
# eof Rating.pm