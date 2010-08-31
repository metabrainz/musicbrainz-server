package MusicBrainz::Server::Controller::WS::1::Rating;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

use MusicBrainz::Server::Data::Utils qw( type_to_model );

with 'MusicBrainz::Server::Controller::WS::1::Role::LoadEntity';
with 'MusicBrainz::Server::Controller::WS::1::Role::Serializer';
with 'MusicBrainz::Server::Controller::WS::1::Role::XMLGeneration';

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

            $model->rating->update($c->user->id, $entity->id, $rating * 20);
        }
        else {
            my @batch;

            for(my $count = 0;; $count++) {
                my $entity = $c->req->params->{"entity.$count"};
                my $id = $c->req->params->{"id.$count"};
                my $rating = $c->req->params->{"rating.$count"};

                last if (!$entity || !$id || !$rating) || @batch >= 20;

                push @batch, { entity => $entity, id => $id, rating => $rating * 20 };
            }

            for my $submission (@batch) {
                my ($model, $entity) = $self->load($c, $submission->{entity}, $submission->{id});

                $model->rating->update($c->user->id, $entity->id, $submission->{rating});
            }
        }

        $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
        $c->res->body($self->serializer->xml( '' ));
    }
    else {
        my ($id, $type)      = ($c->req->query_params->{id}, $c->req->query_params->{entity});
        my ($model, $entity) = $self->load($c, $type, $id);

        $model->rating->load_user_ratings($c->user->id, $entity);

        $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
        $c->res->body(
            $self->serializer->xml(
                $entity->user_rating ? $self->gen->user_rating(int($entity->user_rating / 20)) : ''
            )
        );
    }
}

__PACKAGE__->meta->make_immutable;
1;


