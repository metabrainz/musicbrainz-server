#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        'SELECT id, data AS data_json FROM edit WHERE type = 91'
    )
};

$c->raw_sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data_json});

    delete $data->{new}{link_type}
        unless %{ $data->{new}{link_type} || {} };

    delete $data->{old}{link_type}
        unless %{ $data->{old}{link_type} || {} };

    delete $data->{new}{entity0}
        unless %{ $data->{new}{entity0} || {} };

    delete $data->{new}{entity1}
        unless %{ $data->{new}{entity1} || {} };

    delete $data->{old}{entity1}
        unless %{ $data->{old}{entity1} || {} };

    delete $data->{old}{entity0}
        unless %{ $data->{old}{entity0} || {} };

    $c->raw_sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->raw_sql->commit;
