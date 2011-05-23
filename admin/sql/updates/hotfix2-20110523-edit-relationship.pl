#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use aliased 'MusicBrainz::Server::Entity::CoreEntity';

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( type_to_model );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        'SELECT id, data AS data_json FROM edit WHERE type = 91'
    )
};

$c->raw_sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

# First pass to try and figure out what data we need to load
my %load = (
    map {
        $_ => []
    } qw( Artist Label Recording Release ReleaseGroup URL Work LinkType )
);
for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data_json});

    push @{ $load{LinkType} },
        $data->{link}{link_type_id},
        $data->{new}{link_type_id},
        $data->{old}{link_type_id};

    push @{ $load{type_to_model($data->{type0})} },
        $data->{link}{entity0_id},
        $data->{new}{entity0_id},
        $data->{old}{entity0_id};

    push @{ $load{type_to_model($data->{type1})} },
        $data->{link}{entity1_id},
        $data->{new}{entity1_id},
        $data->{old}{entity1_id};
}

my %loaded = map {
    $_ => $c->model($_)->get_by_ids(grep { $_ } @{ $load{$_} })
} keys %load;

my $deleted = CoreEntity->new( id => 0, name => '[removed]' );

# Upgrade the data
for my $edit (@to_fix) {
    my $data = $edit->{data};

    my $model0 = type_to_model($data->{type0});
    my $model1 = type_to_model($data->{type1});

    my $lt_id = delete $data->{link}{link_type_id};
    my $lt = $loaded{LinkType}{ $lt_id };
    $data->{link}{link_type} = {
        id => $lt->id,
        name => $lt->name,
        link_phrase => $lt->link_phrase,
        reverse_link_phrase => $lt->reverse_link_phrase
    };

    if (my $id = delete $data->{link}{entity0_id}) {
        my $ent = $loaded{ $model0 }{ $id } || $deleted;
        $data->{link}{entity0} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{link}{entity1_id}) {
        my $ent = $loaded{ $model1 }{ $id } || $deleted;
        $data->{link}{entity1} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{new}{entity0_id}) {
        my $ent = $loaded{ $model0 }{ $id } || $deleted;
        $data->{new}{entity0} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{new}{entity1_id}) {
        my $ent = $loaded{ $model1 }{ $id } || $deleted;
        $data->{new}{entity1} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{old}{entity0_id}) {
        my $ent = $loaded{ $model0 }{ $id } || $deleted;
        $data->{old}{entity0} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{old}{entity1_id}) {
        my $ent = $loaded{ $model1 }{ $id } || $deleted;
        $data->{old}{entity1} = {
            id => $ent->id,
            name => $ent->name
        };
    }

    if (my $id = delete $data->{new}{link_type_id}) {
        my $lt = $loaded{LinkType}{ $id };
        $data->{new}{link_type} = {
            name => $lt->name,
            link_phrase => $lt->link_phrase,
            reverse_link_phrase => $lt->reverse_link_phrase,
            id => $lt->id
        };
    }

    if (my $id = delete $data->{old}{link_type_id}) {
        my $lt = $loaded{LinkType}{ $id };
        $data->{old}{link_type} = {
            name => $lt->name,
            link_phrase => $lt->link_phrase,
            reverse_link_phrase => $lt->reverse_link_phrase,
            id => $lt->id
        };
    }

    $c->raw_sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->raw_sql->commit;
