package MusicBrainz::Server::Data::Role::LinksToEdit;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

method edit_link_table { $self->table->name }

before merge => sub {
    my ($self, $new_id, @old_ids) = @_;
    $self->c->model('Edit')->merge_entities($self->table->name, $new_id, @old_ids);
};

1;
