package MusicBrainz::Server::Model::PUID;

use strict;
use warnings;

use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config(class => 'MusicBrainz::Server::PUID');

sub prepare_arguments
{
    my ($self, $c) = @_;
    return $c->mb->dbh;
}

1;