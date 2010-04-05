package MusicBrainz::Server::Data::Role::Relationship;
use Moose::Role;
use namespace::autoclean;

before '_delete' => sub {
    my ($self, @ids) = @_;
    $self->c->model('Relationship')->delete_entities($self->table->name, @ids);
};

before merge => sub {
    my ($self, $new_id, @old_ids) = @_;
    $self->c->model('Relationship')->merge_entities($self->table->name,
                                                    $new_id, @old_ids);
};

1;
