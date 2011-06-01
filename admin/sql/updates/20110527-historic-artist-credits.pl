#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE $EDIT_RELEASEGROUP_EDIT );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        q{SELECT id, data, type FROM edit
           WHERE type IN (20, 21)
             AND data LIKE '%"artist_credit"%'
             AND data NOT LIKE '%"names"%'}
    )
};

$c->raw_sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    if ($edit->{type} == $EDIT_RELEASEGROUP_EDIT) {
        $data->{$_}{artist_credit} = upgrade_artist_credit($data->{$_}{artist_credit})
            for qw( new old );
    }
    elsif ($edit->{type} == $EDIT_RELEASEGROUP_CREATE) {
        $data->{artist_credit} = upgrade_artist_credit($data->{artist_credit});
    }

    $c->raw_sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->raw_sql->commit;

sub upgrade_artist_credit {
    my $ac = shift;
    my @ac = @$ac;
    my @upgraded;
    while(@ac) {
        my $artist_credit_name = shift(@ac);
        my $join_phrase = shift(@ac) if @ac;

        push @upgraded, {
            artist => {
                id =>$artist_credit_name->{artist},
                name => $artist_credit_name->{name},
            },
            name => $artist_credit_name->{name},
            join_phrase => $join_phrase
        }
    }

    return {
        names => \@upgraded
    };
}
