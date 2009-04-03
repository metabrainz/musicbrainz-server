package MusicBrainz::Server::Model::Alias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use MusicBrainz::Server::Alias;

sub load_for_entity
{
    my ($self, $entity) = @_;

    my $type  = (ucfirst $entity->entity_type);
    my $table = "${type}Alias";

    my $alias   = MusicBrainz::Server::Alias->new($self->dbh, $table);
    my $aliases = [ $alias->load_all($entity->id) ];

    return $aliases;
}

sub load
{
    my ($self, $entity, $id) = @_;

    my $type = (ucfirst $entity->entity_type);
    my $table = "${type}Alias";

    my $alias = new MusicBrainz::Server::Alias($self->dbh, $table);
    $alias->id($id);

    $alias->LoadFromId or return;

    return $alias;
}

1;
