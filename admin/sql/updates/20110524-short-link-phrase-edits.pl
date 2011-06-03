#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE $EDIT_RELATIONSHIP_EDIT );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        'SELECT id, type, data AS data_json FROM edit WHERE type IN (?, ?)',
        $EDIT_RELATIONSHIP_CREATE,
        $EDIT_RELATIONSHIP_EDIT
    )
};

$c->raw_sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

my @link_type_ids;

# First pass just to find out which link types we need to load
for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data_json});
    if($edit->{type} == $EDIT_RELATIONSHIP_CREATE) {
        push @link_type_ids, $data->{link_type}{id};
    }
    elsif($edit->{type} == $EDIT_RELATIONSHIP_EDIT) {
        push @link_type_ids, $data->{link}{link_type}{id} if $data->{link}{link_type};
        push @link_type_ids, $data->{old}{link_type}{id} if $data->{old}{link_type};
        push @link_type_ids, $data->{new}{link_type}{id} if $data->{new}{link_type};
    }
}

my %link_type = %{ $c->model('LinkType')->get_by_ids(grep { $_ } @link_type_ids) };

# Upgrade the data
for my $edit (@to_fix) {
    my $data = $edit->{data};

    if ($edit->{type} == $EDIT_RELATIONSHIP_CREATE) {
        my $link_type = $link_type{ $data->{link_type}{id} };
        $data->{link_type}{short_link_phrase} =
            $link_type ? $link_type->short_link_phrase : $data->{link_type}{link_phrase};
    }
    elsif ($edit->{type} == $EDIT_RELATIONSHIP_EDIT) {
        if (my $link_type_id = $data->{link}{link_type}{id}) {
            my $link_type = $link_type{ $link_type_id };
            $data->{link}{link_type}{short_link_phrase} =
                $link_type ? $link_type->short_link_phrase : $data->{link}{link_type}{link_phrase};
        }

        if ($data->{new}{link_type} && $data->{new}{link_type}{id}) {
            my $link_type = $link_type{ $data->{new}{link_type}{id} };
            $data->{new}{link_type}{short_link_phrase} =
                $link_type ? $link_type->short_link_phrase : $data->{new}{link_type}{link_phrase};
        }

        if ($data->{old}{link_type} && $data->{old}{link_type}{id}) {
            my $link_type = $link_type{ $data->{old}{link_type}{id} };
            $data->{old}{link_type}{short_link_phrase} =
                $link_type ? $link_type->short_link_phrase : $data->{old}{link_type}{link_phrase};
        }
    }

    $c->raw_sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->raw_sql->commit;
