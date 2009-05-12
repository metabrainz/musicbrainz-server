package MusicBrainz::Server::ModelFactory;

use base 'Catalyst::Model::Factory::PerRequest';

sub prepare_arguments
{
    my ($self, $c) = @_;
    return { c => $c };
}

1;
