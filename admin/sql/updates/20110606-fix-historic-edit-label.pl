#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $EDIT_LABEL_EDIT
);
use MusicBrainz::Server::Data::Utils qw( type_to_model );

my $c = MusicBrainz::Server::Context->create_script_context;
my $json = JSON::Any->new( utf8 => 1 );

my @to_fix = @{
    $c->raw_sql->select_list_of_hashes(
        q|SELECT id, data FROM edit WHERE type = ? AND data LIKE '%"entity_id":%'|,
        $EDIT_LABEL_EDIT
    )
};

$c->raw_sql->begin;

my @label_ids;
for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});
    push @label_ids, $data->{entity_id};
};

my %labels = %{ $c->model('Label')->get_by_ids(@label_ids) };

for my $edit (@to_fix) {
    my $label_id = delete $edit->{data}->{entity_id};
    $edit->{data}->{entity} = {
        id => $label_id,
        name => $labels{$label_id} ? $labels{$label_id}->name : '[removed]'
    };

    $c->raw_sql->do('UPDATE edit SET data = ? WHERE id = ?', $json->objToJson($edit->{data}), $edit->{id});
}

$c->raw_sql->commit;
