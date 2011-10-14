#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT edit.id, edit.data, edit.type, mod.newvalue
            FROM edit
            JOIN public.moderation_closed mod ON mod.id = edit.id
           WHERE edit.type = 210 OR edit.type = 208}
            # 210 = Change Track Artist
            # 208 = Move Release
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});
    my $type = $edit->{type};

    my ($sort_name, $name) = split /\n/, $edit->{newvalue};
    $name //= $sort_name;

    if ($type == 210) {
        $data->{new_artist_name} = $name;
    }
    elsif ($type == 208) {
        $data->{artist_name} = $name;
    }

    $c->sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->sql->commit;
