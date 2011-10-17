#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_REMOVE_ISRC );
use MusicBrainz::Server::Types qw( $STATUS_OPEN );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data FROM edit
           WHERE type = ?
             AND status = ?},
        $EDIT_RECORDING_REMOVE_ISRC,
        $STATUS_OPEN
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    $c->sql->do(
        'UPDATE isrc SET edits_pending = edits_pending + 1 WHERE id = ?',
        $data->{isrc}{id}
    );
}

$c->sql->commit;
