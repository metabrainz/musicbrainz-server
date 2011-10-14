#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use List::MoreUtils qw( uniq );
use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADDRELEASELABEL );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data FROM edit
           WHERE type = ? AND data NOT LIKE '%entity_id%'},
        $EDIT_RELEASE_ADDRELEASELABEL
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    $data->{entity_id} = $c->sql->select_single_value(
        'SELECT id
           FROM release_label
          WHERE label IS NOT DISTINCT FROM ?
            AND catalog_number IS NOT DISTINCT FROM ?
            AND release IS NOT DISTINCT FROM ?',
        $data->{label}{id},
        $data->{catalog_number},
        $data->{release}{id}
    ) || 0;

    $c->sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->sql->commit;
