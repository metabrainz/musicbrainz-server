package MusicBrainz::Server::Controller::Rating;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );

=head1 NAME

MusicBrainz::Server::Controller::Rating

=head1 DESCRIPTION

Handles user interaction Ratings

=head1 METHODS

=cut

sub rate : Local RequireAuth DenyWhenReadonly
{
    my ($self, $c, $type) = @_;

    my $entity_type = $c->request->params->{entity_type};
    my $entity_id = $c->request->params->{entity_id};
    my $rating = int($c->request->params->{rating});

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

1;
