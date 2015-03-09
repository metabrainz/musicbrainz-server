package MusicBrainz::Server::Controller::Role::Collection;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

parameter 'entity_name' => (
    isa => 'Str',
    required => 1
);

role
{
    my $params = shift;
    my $entity_name = $params->entity_name;

    # Stuff that has the side bar and thus needs to display collection information
    method _stash_collections => sub {
        my ($self, $c) = @_;

        my $entity = $c->stash->{$entity_name};

        my @collections;
        my %containment;
        if ($c->user_exists) {
            # Make a list of collections and whether this entity is contained in them
            @collections = $c->model('Collection')->find_all_by_editor($c->user->id, 1, $entity_name);
            foreach my $collection (@collections) {
                $containment{$collection->id} = 1
                  if ($c->model('Collection')->contains_entity($entity_name, $collection->id, $entity->id));
            }
        }

        my @all_collections = $c->model('Collection')->find_all_by_entity($entity_name, $entity->id);

        $c->stash(
                  collections => \@collections,
                  containment => \%containment,
                  all_collections => \@all_collections,
        );
    };

    method _collections => sub {
        my ($self, $c) = @_;

        my @all_collections = $c->model('Collection')->find_all_by_entity($entity_name, $c->stash->{$entity_name}->id);
        my @public_collections;
        my $private_collections = 0;

        # Keep public collections;
        # count private collection
        foreach my $collection (@all_collections) {
            push(@public_collections, $collection)
              if ($collection->{'public'} == 1);
            $private_collections++
              if ($collection->{'public'} == 0);
        }

        $c->model('Editor')->load(@public_collections);

        $c->stash(
           public_collections => \@public_collections,
           private_collections => $private_collections,
        );
    };
};

1;
