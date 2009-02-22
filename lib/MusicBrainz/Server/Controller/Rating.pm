package MusicBrainz::Server::Controller::Rating;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Label;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Rating

=head1 DESCRIPTION

Handles user interaction Ratings

=head1 METHODS

=head2 index

Redirects to /ratings/display

=cut

sub index : Private
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->detach('display', [ $c->user->id, 'all' ]);
}

=head2 display

Display all of a users ratings, for a specifc entity type

=cut

sub display : Path('display') Args(2)
{
    my ($self, $c, $user_id, $entity_type) = @_;

    die "$entity_type is not a valid type of entity"
        unless grep { $entity_type eq $_ } qw/ artist label track release all/;
    my @entity_types = ($entity_type eq 'all') ? ("artist", "label", "release", "track") : ($entity_type);

    if ($user_id eq $c->user->id)
    {
         $c->stash->{user}     = $c->user;
         $c->stash->{can_rate} = 1;
         $c->stash->{can_view} = 1;
    }
    else
    {
        my $user = $c->model('User')->load({ id => $user_id })
            or $c->detach('/error_404');

        $c->stash->{user}     = $user;
        $c->stash->{can_view} = $user->preferences->get("ratings_public");
    }

    use constant ENTITIES_PER_PAGE => '100';
    use constant ENTITIES_PER_SMALL_PAGE => '10';

    my $page_number = $c->req->query_params->{page} || 1;
    my $limit       = $entity_type eq 'all' ? 10 : 100;
    my $offset      = ($limit, ENTITIES_PER_PAGE * ($page_number - 1));
    foreach my $entity_type (@entity_types) 
    {
        my ($ratings, $rating_count) 
            = $c->model('Rating')->get_all_user_ratings_for_entity_type($entity_type, $user_id, $limit, $offset);

         $c->stash->{ratings}->{$entity_type}->{ratings} = $ratings;
         $c->stash->{ratings}->{$entity_type}->{count}   = $rating_count;
    }

    # Create a Data::Page object which deals with pagination
    my $pager = Data::Page->new;
    $pager->current_page($page_number);
    $pager->entries_per_page(ENTITIES_PER_PAGE);
    $pager->total_entries( $c->stash->{ratings}->{$entity_type}->{count});

    $c->stash->{pager}                 = $pager;
    $c->stash->{requested_entity_type} = $entity_type;
    $c->stash->{limit}                 = $entity_type eq 'all' ? ENTITIES_PER_SMALL_PAGE : ENTITIES_PER_PAGE;
    $c->stash->{entity_types}          = \@entity_types;
    $c->stash->{template}              = 'rating/display.tt';
}

sub rate : Path('rate') Args(3) 
{
    my ($self, $c, $entity_type, $entity_id, $new_vote) = @_;

    $c->forward('/user/login');
    $c->forward('/rating/do_rating');

    if (defined $c->request->param('JSON')) 
    {
        $c->stash->{json} = {
            "entitytype"     => $entity_type,
            "entityid"       => $entity_id,
            "average_rating" => $c->stash->{average_rating},
            "rating_count"   => $c->stash->{rating_count},
            "userid"         => $c->user->id,
            "user_rating"    => $new_vote,
        };

        $c->detach($c->view('JSON'));
    }
    else 
    {
        $c->detach('display', [ $c->user->id, 'all' ]);
    }
}

sub do_rating : Private
{
    my ($self, $c, $entity_type, $entity, $new_vote) = @_;
    ( $c->stash->{average_rating}, $c->stash->{rating_count} ) = $c->model('Rating')->update($entity_type, $entity, $c->user->id, $new_vote);
}

1;
