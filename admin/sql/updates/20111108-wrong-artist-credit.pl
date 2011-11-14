#!/usr/bin/env perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

$c->sql->begin;

binmode(STDOUT, ":utf8");

my %current_names = map { $_->[0] => $_->[1] } @{
    $c->sql->select_list_of_lists(
        'SELECT ac.id, an.name
           FROM artist_credit ac
           JOIN artist_name an ON ac.name = an.id')
};

my $partial_names = $c->sql->select_list_of_hashes(
    'SELECT acn.artist_credit AS id, acn.join_phrase, an.name
       FROM artist_credit_name acn
       JOIN artist_name an ON acn.name = an.id
   ORDER BY artist_credit, position');

my %names;
for my $name (@$partial_names) {
    my $id = $name->{id};
    $names{$id} ||= '';
    $names{$id} .= $name->{name};
    $names{$id} .= $name->{join_phrase} if defined $name->{join_phrase};
}

my %missing_names;
for my $id (keys %current_names) {
    if ($names{$id} ne $current_names{$id}) {
        $missing_names{$id} = $names{$id};
        print "Artist credit ($id) is wrong '" . $names{$id} ."' '" . $current_names{$id} . "'\n";
    }
}

my %names_id = $c->model('Artist')->find_or_insert_names(values %missing_names);
for my $id (keys %missing_names) {
    $c->sql->do('UPDATE artist_credit SET name = ? WHERE id = ?',
                 $names_id{$missing_names{$id}}, $id);
}

$c->sql->commit;

