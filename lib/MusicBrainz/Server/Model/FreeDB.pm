package MusicBrainz::Server::Model::FreeDB;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

# needed since this doesn't stub to the usual data class
sub _entity_class
{
    return 'MusicBrainz::Server::Entity::FreeDB';
}

sub load
{
    my ($self, $id, $category) = @_;

}

1;
