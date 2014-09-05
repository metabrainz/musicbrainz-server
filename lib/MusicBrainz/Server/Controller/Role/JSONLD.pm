package MusicBrainz::Server::Controller::Role::JSONLD;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

parameter 'endpoints' => (
    isa => 'ArrayRef',
    required => 0,
    default => sub { [] }
);

role
{
    my $params = shift;

    my $endpoints = $params->endpoints;

    requires 'load';

    after load => sub {
        my ($self, $c, @args) = @_;
        $c->stash->{jsonld_stash} = WebServiceStash->new();
    };

    after @$endpoints => sub {
        my ($self, $c, @args) = @_;
        $c->stash->{jsonld_data} = serialize_entity($c->stash->{entity}, undef, $c->stash->{jsonld_stash}, 1);
    };
};

1;
