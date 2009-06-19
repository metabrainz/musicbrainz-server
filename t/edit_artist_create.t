#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Artist::Create';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $sql = Sql->new($c->raw_dbh);
$sql->Begin;

my $edit = MusicBrainz::Server::Edit::Artist::Create->create(
    {
        name => 'Junior Boys',
        gender => 1,
        comment => 'Canadian electronica duo',
    },
    c => $c,
    editor_id => 1
);

$edit_data->insert($edit);
ok(defined $edit->artist_id);
ok(defined $edit->id);
is_deeply($edit->to_hash, {
        name => 'Junior Boys',
        gender => 1,
        comment => 'Canadian electronica duo',
        artist_id => $edit->artist_id,
    });

$sql->Commit;
