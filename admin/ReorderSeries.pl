#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;
use Time::HiRes qw( sleep );

my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');
my $rows = $c->sql->select_single_row_hash('SELECT min(id) AS min_id, max(id) AS max_id FROM series');

for my $id ($rows->{min_id} .. $rows->{max_id}) {
    print "Reordering series id=$id\n";

    Sql::run_in_transaction(sub {
        # automatically_reorder will return if the id doesn't exist, or if the
        # series is manually ordered
        $c->model('Series')->automatically_reorder($id);
    }, $c->sql);

    # Let things breathe
    sleep(0.1);
}
