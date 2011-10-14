#!/usr/bin/env perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;
my @pairs = $c->model('Relationship')->all_pairs;

$c->sql->begin;

for my $pair (@pairs) {
    my ($a, $b) = @$pair;
    $c->sql->do("CREATE INDEX l_${a}_${b}_link_idx ON l_${a}_${b} (link)");
}

$c->sql->do(
      'SELECT id INTO TEMPORARY tmp_unused_links FROM ('
    . join(' UNION ', map {
        my ($a, $b) = @$_;
        "(SELECT link.id FROM link
         JOIN link_type ON link_type.id = link_type
         WHERE entity_type0 = '$a' AND entity_type1 = '$b'
         AND NOT EXISTS (
           SELECT TRUE FROM l_${a}_${b} WHERE link = link.id
           LIMIT 1
         ))"
      } @pairs)
    . ') s'
);

$c->sql->do('DELETE FROM link_attribute WHERE link IN (SELECT id FROM tmp_unused_links)');
$c->sql->do('DELETE FROM link WHERE id IN (SELECT id FROM tmp_unused_links)');

for my $pair (@pairs) {
    my ($a, $b) = @$pair;
    $c->sql->do("DROP INDEX l_${a}_${b}_link_idx");
}

$c->sql->commit;
