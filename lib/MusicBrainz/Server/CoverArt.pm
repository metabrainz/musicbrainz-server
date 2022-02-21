package MusicBrainz::Server::CoverArt;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Entity::Role::LastUpdate';

use MooseX::Types::URI qw( Uri );

has 'image_uri' => (
    isa => Uri,
    is  => 'ro',
    coerce => 1
);

has 'provider' => (
    does => 'MusicBrainz::Server::CoverArt::Provider',
    is  => 'ro',
);

has 'information_uri' => (
    isa => Uri,
    is  => 'rw',
    coerce => 1,
);

sub cache_data
{
    my $self = shift;
    my $data = {};
    $data->{info_url} = $self->information_uri
        if $self->information_uri;
    return $data;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        image_uri => $self->image_uri->as_string,
        information_uri => $self->information_uri->as_string,
    };
}

1;
