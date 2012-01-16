package MusicBrainz::Server::Controller::Role::WebServiceEdit;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

parameter 'form' => (
    isa => 'Str',
    required => 1
);

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            edit => { Chained => 'load', RequireAuth => undef, Edit => undef }
        }
    );

    method 'edit' => sub { };
};

1;
