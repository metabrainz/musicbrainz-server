package MusicBrainz::Server::Model::Alias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use MusicBrainz::Server::Alias;
use MusicBrainz::Server::Facade::Alias;

sub load_for_entity
{
    my ($self, $entity) = @_;

    my $type  = (ucfirst $entity->entity_type);
    my $table = "${type}Alias";

    my $alias   = MusicBrainz::Server::Alias->new($self->dbh, $table);
    my $aliases = $alias->LoadFull($entity->id);

    return $aliases;
}

1;
