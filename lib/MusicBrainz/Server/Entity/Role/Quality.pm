package MusicBrainz::Server::Entity::Role::Quality;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Types qw( Quality );

has 'quality' => (
    isa => Quality,
    is  => 'rw',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{quality} = $self->quality;
    return $json;
};

1;
