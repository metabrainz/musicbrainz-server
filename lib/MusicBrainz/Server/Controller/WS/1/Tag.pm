package MusicBrainz::Server::Controller::WS::1::Tag;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_TAG );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of );
use Readonly;

with 'MusicBrainz::Server::Controller::WS::1::Role::LoadEntity';

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => Data::OptList::mkopt([
         tag => {
             method => 'GET',
         },
         tag => {
             method => 'POST'
         }
     ]),
     version => 1,
};

our Readonly $MAX_TAGS_PER_REQUEST = 20;

use MusicBrainz::Server::Validation qw( is_guid );

sub tag : Path('/ws/1/tag')
{
    my ($self, $c) = @_;

    $self->authenticate($c, $ACCESS_SCOPE_TAG);

    if ($c->req->method eq 'POST') {
        $self->deny_readonly($c);
        if (exists $c->req->params->{entity}) {
            # Looks like a single entity tag submission
            my ($id, $type, $tags) = (
                map {
                    $c->req->params->{$_}
                } qw( id entity tags )
            );

            my ($model, $entity) = $self->load($c, $type, $id);
            $model->tags->update($c->user->id, $entity->id, $tags);
        }
        else {
            my @batch;

            for(my $count = 0;; $count++) {
                my $entity = $c->req->params->{"entity.$count"};
                my $id = $c->req->params->{"id.$count"};
                my $tags = $c->req->params->{"tags.$count"};

                last if (!$entity || !$id || !$tags);

                push @batch, { entity => $entity, id => $id, tags => $tags };
            }

            if (!@batch) {
                $self->bad_req($c, 'No valid tags were specified in this request');
            }

            if (@batch > $MAX_TAGS_PER_REQUEST) {
                $self->bad_req($c, "Too many tags for one request. Max $MAX_TAGS_PER_REQUEST tags per request");
            }

            for my $submission (@batch) {
                my ($model, $entity) = $self->load($c, $submission->{entity}, $submission->{id});
                $model->tags->update($c->user->id, $entity->id, $submission->{tags});
            }
        }

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->xml( '' ));
    }
    else {
        my ($id, $type)      = ($c->req->query_params->{id}, $c->req->query_params->{entity});
        $self->bad_req($c, 'Invalid argument "id": not a valid MBID') unless is_guid($id);
        $self->bad_req($c, 'Invalid argument "entity": not a valid entity type') if ref($type);

        my ($model, $entity) = $self->load($c, $type, $id);

        my @tags = $model->tags->find_user_tags($c->user->id, $entity->id);

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->xml( list_of([ map { $_->tag } @tags ]) ));
    }
}

__PACKAGE__->meta->make_immutable;
1;


