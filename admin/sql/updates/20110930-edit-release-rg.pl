#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDIT
);
use Try::Tiny;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data, type FROM edit
           WHERE type = ?},
        $EDIT_RELEASE_EDIT
    )
};

my $json = JSON::Any->new( utf8 => 1 );

$c->sql->begin;
for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    for my $v (qw( old new) ) {
        my $rg_id = $data->{$v}{release_group_id}
            or next;
        try {
            $c->sql->do('SAVEPOINT rg_link');
            $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $rg_id);
        }
        catch {
            $c->sql->do('ROLLBACK TO SAVEPOINT rg_link');
        }
        finally {
            $c->sql->do('RELEASE SAVEPOINT rg_link');
        };
    }
}

$c->sql->commit;
