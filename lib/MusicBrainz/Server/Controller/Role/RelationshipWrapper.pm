package MusicBrainz::Server::Controller::Role::RelationshipWrapper;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub load_relationships
{
    my ($self, $c, $types) = @_;

    my $entity = $c->stash->{entity};
    my @rels;

    if ($types) {
        @rels = $c->model('Relationship')->load_subset($types, $entity);

        if ('url' ~~ $types) {
            $self->url_relationships_loaded($c);
        }
    } else {
        @rels = $c->model('Relationship')->load($entity);
        $self->url_relationships_loaded($c);
    }

    return @rels;
}

sub url_relationships_loaded
{
    # Dummy method that's being used to trigger the loading of
    # MusicBrainz::Server::Controller::Role::CommonsImage
}


no Moose::Role;
1;