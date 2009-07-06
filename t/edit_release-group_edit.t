#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

BEGIN { use_ok 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::ReleaseGroup;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);
my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $rg = $rg_data->get_by_id(3);

my $edit = $edit_data->create(
    edit_type => $EDIT_RELEASEGROUP_EDIT,
    release_group => $rg,
    artist_credit => [
        { name => 'Break', artist => 3 },
        ' & ',
        { name => 'Silent Witness', artist => 4 },
    ],
    name => 'We Know',
    comment => 'EP',
    editor_id => 2,
);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Edit');
is($edit->entity_model, 'ReleaseGroup');
is($edit->entity_id, $rg->id);
is_deeply($edit->entities, { release_group => [ $rg->id ] });

is_deeply($edit->data, {
        release_group => $rg->id,
        new => {
            name => 'We Know',
            artist_credit => [
                { name => 'Break', artist => 3 },
                ' & ',
                { name => 'Silent Witness', artist => 4 },
            ],
            comment => 'EP',
        },
        old => {
            name => $rg->name,
            comment => $rg->comment,
            artist_credit => [
                { name => 'Test Artist', artist => 3 }
            ],
        },
    });

$rg = $rg_data->get_by_id(3);
is($rg->edits_pending, 1);

$edit_data->accept($edit);

$rg = $rg_data->get_by_id(3);
$ac_data->load($rg);
is($rg->name, 'We Know');
is($rg->comment, 'EP');
is($rg->artist_credit->name, 'Break & Silent Witness');
is($rg->edits_pending, 0);
