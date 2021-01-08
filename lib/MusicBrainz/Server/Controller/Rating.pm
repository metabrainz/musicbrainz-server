package MusicBrainz::Server::Controller::Rating;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use Scalar::Util qw( looks_like_number );

=head1 NAME

MusicBrainz::Server::Controller::Rating

=head1 DESCRIPTION

Handles user interaction Ratings

=head1 METHODS

=cut

sub rate : Local RequireAuth DenyWhenReadonly
{
    my ($self, $c, $type) = @_;

    if (!$c->user->has_confirmed_email_address) {
        $c->detach('/error_401');
    }

    if ($c->is_cross_origin) {
        $c->response->redirect($c->uri_for('/'));
    }

    my $entity_type = $c->request->params->{entity_type};
    my $entity_id = $c->request->params->{entity_id};
    my $rating = $c->request->params->{rating};

    unless (looks_like_number($rating)) {
        $self->error( $c, message => 'rating must be a number', status => 400 );
    }

    my $model = $c->model(type_to_model($entity_type));
    my ($sum, $count) = $model->rating->update($c->user->id, $entity_id, $rating);

    if ($c->request->params->{json}) {
        my $body = $c->json_utf8->encode({
            rating         => $rating,
            rating_average => $count > 0 ? ($sum / $count) : 0,
            rating_count   => $count,
        });
        $c->response->body($body);
        $c->response->content_type('application/json; charset=utf-8');
        $c->detach;
    }

    $c->redirect_back;
}

1;
