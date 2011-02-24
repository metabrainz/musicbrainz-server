package MusicBrainz::Server::WebService::Resource::2::Recording::GET;
use Moose;
use namespace::clean;

with 'MusicBrainz::Server::WebService::Method';

has '+request_data_class' => (
    default => 'MusicBrainz::Server::WebService::Resource::2::Recording::GET::Params'
);

sub execute {
    my ($self, $input) = @_;
    
}

1;
