package MusicBrainz::Server::Data::Role::Joined;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

has 'parent' => (
    isa      => 'MusicBrainz::Server::Data::FeyEntity',
    is       => 'ro',
    required => 1
);

has '_join_column' => (
    is => 'ro',
    lazy_build => 1
);

method type { $self->_join_column->name }

method _build__join_column {
    my ($fk) = $self->table->schema
        ->foreign_keys_between_tables($self->table, $self->parent->table);

    return $fk->source_columns->[0];
}

1;
