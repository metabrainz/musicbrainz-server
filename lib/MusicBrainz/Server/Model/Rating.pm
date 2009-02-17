package MusicBrainz::Server::Model::Rating;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

#use Carp;
#use List::Util qw(min max sum);
use MusicBrainz::Server::Rating;
use Data::Dumper;

=head1 NAME

MusicBrainz::Server::Model::Rating

=head1 DESCRIPTION

Provides a Ratings Model (by accessing the old Model)

=head1 METHODS

=head2 update

Update a vote (works for new votes as well)

=cut

sub update 
{
    my ($self, $entity_type, $entity_id, $user_id, $new_vote, $old_vote ) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);
    
    my ( $average_rating, $rating_count ) = $rating->Update($entity_type, $entity_id, $user_id, $new_vote);
    return $average_rating, $rating_count;
}

=head2 Merge

Merge a vote when you merge an entity

=cut


sub merge
{
    my ($self, $entity_type, $old_id, $new_id) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);
    $rating->merge( $entity_type, $old_id, $new_id);
}

=head2 Remove

Remove a vote when you merge an entity

=cut


sub remove
{
    my ($self, $entity_type, $old_id, $new_id) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);
    $rating->delete( $entity_type, $old_id, $new_id);

}



=head2 get_all_user_ratings_for_entity_type

get all the user ratings for a given entity type (votes for all artists, all lables, etc)

=cut

sub get_all_user_ratings_for_entity_type 
{
    my ($self, $entity_type, $user_id, $limit, $offset) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);
    my ($results, $count) = $rating->GetEntitiesRatingsForUser($entity_type, $user_id, $limit, $offset);

    return ($results, $count);
}


=head2 get_user_rating_for_entity

get single rating for given entity and user

=cut

sub get_user_rating_for_entity 
{
    my ($self, $entity_type, $entity_id, $user_id) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);

    return $rating->GetUserRatingForEntity($entity_type, $entity_id, $user_id);
}


sub get_average_rating_for_entity
{
    my ($self, $entity_type, $entity_id) = @_;

    my $rating = MusicBrainz::Server::Rating->new($self->dbh);
    
    return $rating->GetRatingForEntity($entity_type, $entity_id);
}

#params_ref should contain
#entity_type
#entity_id
#user_id

sub get_rating {
    my ($self, $params_ref) = @_;

    if ( $params_ref->{user_id} ) {
        $params_ref->{user_can_rate} = 1;
        $params_ref->{score} = $self->get_user_rating_for_entity(   $params_ref->{entity_type}, 
                                                                    $params_ref->{entity_id}, 
                                                                    $params_ref->{user_id},
                                                                );
    }
    my $result = $self->get_average_rating_for_entity( $params_ref->{entity_type}, $params_ref->{entity_id} );
    ($params_ref->{average_score}, $params_ref->{count}) = ($result->{rating}, $result->{rating_count});
    $params_ref->{unrated_by_user} = 1 unless $params_ref->{score};
    $params_ref->{score} = 0 unless $params_ref->{score};
    $params_ref->{average_score} = 'none' unless $params_ref->{average_score};
    $params_ref->{count} = 0 unless $params_ref->{count};
    #returns hash with score, average_score, count, user_can_rate;
    return $params_ref;
}



1;
