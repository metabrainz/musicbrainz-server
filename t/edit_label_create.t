#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Label::Create';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Test;

use Sql;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $label_data = MusicBrainz::Server::Data::Label->new(c => $c);

my $sql = Sql->new($c->raw_dbh);
$sql->Begin;

my $edit = MusicBrainz::Server::Edit::Label::Create->create(
    {
        name => '!K7',
        sort_name => '!K7 Recordings',
        type => 1,
        comment => 'Funky record label',
        label_code => 7306,
    },
    c => $c,
    editor_id => 1
);

$edit_data->insert($edit);
ok(defined $edit->label_id);
ok(defined $edit->id);

my $label = $label_data->get_by_id($edit->label_id);
ok(defined $label);
is($label->name, '!K7');
is($label->sort_name, '!K7 Recordings');
is($label->type_id, 1);
is($label->comment, "Funky record label");
is($label->label_code, 7306);

$sql->Commit;
