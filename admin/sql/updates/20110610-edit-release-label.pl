#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        q{SELECT id, data FROM edit
           WHERE type = ?
             AND data LIKE '%"label":{}%'},
        $EDIT_RELEASE_EDITRELEASELABEL
    )
};

$c->raw_sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    delete $data->{old}{label}
        if $data->{old}{label} && !%{$data->{old}{label}};

    delete $data->{new}{label}
        if $data->{new}{label} && !%{$data->{new}{label}};

    $c->raw_sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->raw_sql->commit;
