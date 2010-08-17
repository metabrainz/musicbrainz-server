package MusicBrainz::Server::Controller::WS::1::Tag;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use aliased 'MusicBrainz::Server::WebService::XMLSerializerV1';
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

use MusicBrainz::Server::Data::Utils qw( type_to_model );

has 'serializer' => (
    is => 'ro',
    default => sub { XMLSerializerV1->new }
);

sub tag : Path('/ws/1/tag')
{
    my ($self, $c) = @_;
    $c->authenticate({}, 'webservice');

    if ($c->req->method eq 'POST') {
        if (exists $c->req->params->{entity}) {
            # Looks like a single entity tag submission
            my ($id, $type, $tags) = (
                map {
                    $c->req->params->{$_}
                } qw( id entity tags )
            );

            my $model = $c->model( type_to_model($type) );
            my $entity = $model->get_by_gid($id);

            $model->tags->update($c->user->id, $entity->id, $tags);

            $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
            $c->res->body($self->serializer->xml( '' ));
        }
    }
    else {
        my ($id, $type) = ($c->req->query_params->{id}, $c->req->query_params->{entity});

        my $model = $c->model( type_to_model($type) );
        my $entity = $model->get_by_gid($id);
        my @tags = $model->tags->find_user_tags($c->user->id, $entity->id);

        $c->res->content_type($self->serializer->mime_type . '; charset=utf-8');
        $c->res->body($self->serializer->xml( List->new->serialize([ map { $_->tag } @tags ]) ));
    }
}

__PACKAGE__->meta->make_immutable;
1;


