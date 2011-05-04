package MusicBrainz::Server::Controller::WS::1::Rating;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use Readonly;

with 'MusicBrainz::Server::Controller::WS::1::Role::LoadEntity';
with 'MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration';

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => Data::OptList::mkopt([
         rating => {
             method => 'GET',
         },
         rating => {
             method => 'POST'
         }
     ]),
     version => 1,
};

our Readonly $MIN_RATING_VALUE = 0;
our Readonly $MAX_RATING_VALUE = 5;
our Readonly $MAX_RATINGS_PER_REQUEST = 20;

sub rating : Path('/ws/1/rating')
{
    my ($self, $c) = @_;
    $c->authenticate({}, 'musicbrainz.org');

    if ($c->req->method eq 'POST') {
        if (exists $c->req->params->{entity}) {
            # Looks like a single entity rating submission
            my ($id, $type, $rating) = (
                map {
                    $c->req->params->{$_}
                } qw( id entity rating )
            );

            my ($model, $entity) = $self->load($c, $type, $id);

            if (!defined $rating || $rating < $MIN_RATING_VALUE || $rating > $MAX_RATING_VALUE) {
                return $self->bad_req($c, sprintf "Invalid rating value. Must be between %d and %d",
                                      $MIN_RATING_VALUE, $MAX_RATING_VALUE);
            }

            $model->rating->update($c->user->id, $entity->id, $rating * 20);
        }
        else {
            my @batch;

            for(my $count = 0;; $count++) {
                my $entity = $c->req->params->{"entity.$count"};
                my $id = $c->req->params->{"id.$count"};
                my $rating = $c->req->params->{"rating.$count"};

                last unless (defined $entity && defined $rating && defined $id);

                if ($rating < $MIN_RATING_VALUE || $rating > $MAX_RATING_VALUE) {
                    return $self->bad_req($c, sprintf "Invalid rating value. Must be between %d and %d",
                                          $MIN_RATING_VALUE, $MAX_RATING_VALUE);
                }

                push @batch, { entity => $entity, id => $id, rating => $rating * 20 };
            }

            if (@batch > $MAX_RATINGS_PER_REQUEST) {
                $self->bad_req($c, "Too many ratings for one request. Max $MAX_RATINGS_PER_REQUEST ratings per request.");
            }

            if (@batch == 0) {
                $self->bad_req($c, "No valid ratings were specified in this request.");
            }

            for my $submission (@batch) {
                my ($model, $entity) = $self->load($c, $submission->{entity}, $submission->{id});

                $model->rating->update($c->user->id, $entity->id, $submission->{rating});
            }
        }

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->xml( '' ));
    }
    else {
        my ($id, $type)      = ($c->req->query_params->{id}, $c->req->query_params->{entity});
        my ($model, $entity) = $self->load($c, $type, $id);

        $model->rating->load_user_ratings($c->user->id, $entity);

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body(
            $c->stash->{serializer}->xml(
                $entity->user_rating ? $self->gen->user_rating(int($entity->user_rating / 20)) : ''
            )
        );
    }
}

__PACKAGE__->meta->make_immutable;
1;


