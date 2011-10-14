#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Types qw( $STATUS_OPEN );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data FROM edit
           WHERE type = ? AND STATUS = ?},
        $EDIT_PUID_DELETE,
        $STATUS_OPEN
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

my %puid_id;

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    my $puid = $puid_id{$data->{puid_id}} || do {
        my $fetched = $c->model('PUID')->get_by_id($data->{puid_id});
        $puid_id{$data->{puid_id}} = $fetched;
        $fetched
    };

    $c->model('RecordingPUID')->delete($data->{puid_id}, $data->{recording_puid_id});

    $data->{client_version} = $puid->client_version;

    $c->sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->sql->commit;
