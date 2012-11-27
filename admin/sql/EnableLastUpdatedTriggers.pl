#!/usr/bin/env perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

for my $row (@{ $c->sql->select_list_of_lists(
    q{SELECT event_object_table, trigger_name
      FROM information_schema.triggers
      WHERE action_statement LIKE '%b_upd_last_updated_table%'}
) }) {
    my ($table, $trigger) = @$row;
    $c->sql->auto_commit(1);
    $c->sql->do("ALTER TABLE $table ENABLE TRIGGER $trigger");
}
