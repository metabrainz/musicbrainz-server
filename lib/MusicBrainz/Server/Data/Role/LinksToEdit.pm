package MusicBrainz::Server::Data::Role::LinksToEdit;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter 'table' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    method 'edit_link_table' => sub { $params->table }
};

1;
