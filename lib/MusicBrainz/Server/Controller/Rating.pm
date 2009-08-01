package MusicBrainz::Server::Controller::Rating;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Label;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Data::Utils qw( type_to_model );

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

use constant ENTITIES_PER_PAGE => 100;
use constant ENTITIES_PER_SMALL_PAGE => 10;

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

    my $page_number = $c->req->query_params->{page} || 1;
    my $limit       = $entity_type eq 'all' ? 10 : 100;
    my $offset      = ENTITIES_PER_PAGE * ($page_number - 1);
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

sub rate : Local RequireAuth
{
    my ($self, $c, $type) = @_;

    my $entity_type = $c->request->params->{entity_type};
    my $entity_id = $c->request->params->{entity_id};
    my $rating = $c->request->params->{rating};

    my $model = $c->model(type_to_model($entity_type));
    my @result = $model->rating->update($c->user->id, $entity_id, $rating);

    if ($c->request->params->{json}) {
        $c->stash->{json} = {
            rating         => $rating,
            rating_average => $result[0],
            rating_count   => $result[1],
        };
        $c->detach('View::JSON');
    }

    my $redirect = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($redirect);
    $c->detach;
}

sub do_rating : Private
{
    my ($self, $c, $entity_type, $entity, $new_vote) = @_;
    ( $c->stash->{average_rating}, $c->stash->{rating_count} ) = $c->model('Rating')->update($entity_type, $entity, $c->user->id, $new_vote);
}

1;
