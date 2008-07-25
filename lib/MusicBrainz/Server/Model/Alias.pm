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

    my $alias   = MusicBrainz::Server::Alias->new($self->{_dbh}, $table);
    my @aliases = $alias->GetList($entity->id);

    [ map { MusicBrainz::Server::Facade::Alias->new({
        last_used  => $_->[3],
        times_used => $_->[2] || 0,
        name       => $_->[1],
    }) } @aliases ];
}

1;
