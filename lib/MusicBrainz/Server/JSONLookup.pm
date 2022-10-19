package MusicBrainz::Server::JSONLookup;
use strict;
use warnings;

use base 'Exporter';

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Script::JSONDump::Constants qw( %DUMPED_ENTITY_TYPES );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity );

our @EXPORT_OK = qw( json_lookup );

our %ws_controllers;

for my $entity_type (keys %DUMPED_ENTITY_TYPES) {
    my $model = $ENTITIES{$entity_type}{model};
    my $class = 'MusicBrainz::Server::Controller::WS::2::' . $model;
    eval "require $class;";
    $ws_controllers{$entity_type} = $class;
}

sub json_lookup {
    my ($c, $entity_type, $ids) = @_;

    my $inc = $DUMPED_ENTITY_TYPES{$entity_type}{inc};

    # This is not a Catalyst object, it's a MusicBrainz::Server::Context
    # object. But we put a fake stash on it, because that's the entire point
    # of this module. To lookup entity JSON without going through Catalyst.
    $c->stash({ inc => $inc });
    my $stash = WebServiceStash->new;
    $stash->_data->{_json_dump} = 1;

    my $model = $ENTITIES{$entity_type}{model};
    my @entities = values %{ $c->model($model)->get_by_ids(@{$ids}) };

    my $class = $ws_controllers{$entity_type};
    my $toplevel_routine = "${entity_type}_toplevel";
    $class->$toplevel_routine($c, $stash, \@entities);

    my %result;
    for my $entity (@entities) {
        $result{$entity->id} = serialize_entity($entity, $inc, $stash, 1);
    }

    return \%result;
}

1;
