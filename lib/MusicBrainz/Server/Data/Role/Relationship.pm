package MusicBrainz::Server::Data::Role::Relationship;
use Moose::Role;
use namespace::autoclean;

before '_delete' => sub {
    my ($self, @ids) = @_;
    $self->c->model('Relationship')->delete_entities($self->table->name, @ids);
};

1;
