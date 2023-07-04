package MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection;

use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_COLLECTION );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

requires qw(
    authenticate
    make_list
    unauthorized
);

sub browse_by_collection {
    my ($self, $c, $entity_type, $collection_gid, $limit, $offset) = @_;

    my $collection = $c->model('Collection')->get_by_gid($collection_gid);
    $c->detach('not_found') unless $collection;
    $c->model('Editor')->load($collection);

    if (!$collection->public) {
        $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);
        $self->unauthorized($c)
            unless $c->user_exists &&
                    $c->model('Collection')->is_collection_collaborator($c->user->id, $collection->id);
    }

    my $model = $c->model(type_to_model($entity_type));
    my ($entities, $hits) = $model->find_by_collection(
        $collection->id,
        $limit,
        $offset,
    );
    $self->make_list($entities, $hits, $offset);
}

1;
