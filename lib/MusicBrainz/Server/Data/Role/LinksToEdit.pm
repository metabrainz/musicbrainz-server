package MusicBrainz::Server::Data::Role::LinksToEdit;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

method edit_link_table { $self->table->name }

1;
