package MusicBrainz::Server::Controller::Role::JSONLD;
use JSON qw( encode_json );
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );
use aliased 'MusicBrainz::Server::WebService::WebServiceStash';

parameter 'endpoints' => (
    isa => 'HashRef',
    required => 1
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

    for my $endpoint (keys %$endpoints) {
        after $endpoint => sub {
            my ($self, $c, @args) = @_;
            my $entity = $c->stash->{entity};
            my $stash = $c->stash->{jsonld_stash};

            for my $copy (@{ $endpoints->{$endpoint}{copy_stash} // []}) {
                my $from = ref $copy eq 'HASH' ? $copy->{from} : $copy;
                my $to = ref $copy eq 'HASH' ? $copy->{to} : $copy;
                $stash->store($entity)->{$to} = $c->stash->{$from};
            }

            my $jsonld_data = serialize_entity($entity, undef, $stash, 1);

            if ($c->req->header('Accept') eq 'application/ld+json') {
                $c->res->content_type('application/ld+json; charset=utf-8');
                $c->res->body(encode_json($jsonld_data));
                $c->detach;
            } else {
                $c->stash->{jsonld_data} = $jsonld_data;
            }
        };
    }
};

1;
