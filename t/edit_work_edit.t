use strict;
use warnings;
use Test::More tests => 12;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Work::Edit' };

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Work;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_work');

my $work_data = MusicBrainz::Server::Data::Work->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);
my $ac_data = MusicBrainz::Server::Data::ArtistCredit->new(c => $c);

my $work = $work_data->get_by_id(1);
my $edit = $edit_data->create(
    edit_type => $EDIT_WORK_EDIT,
    editor_id => 1,
    work => $work,
    name => 'Edited name',
    comment => 'Edited comment',
    iswc => '123456789123456',
    type_id => 1,
    artist_credit => [
        { artist => 1, name => 'Foo' },
    ]
);

isa_ok($edit, 'MusicBrainz::Server::Edit::Work::Edit');
is($edit->entity_model, 'Work');
is($edit->entity_id, $work->id);
is_deeply($edit->entities, { work => [ $work->id ] });

$work = $work_data->get_by_id(1);
is($work->edits_pending, 1);

$edit_data->accept($edit);

$work = $work_data->get_by_id(1);
$ac_data->load($work);
is($work->name, 'Edited name');
is($work->comment, 'Edited comment');
is($work->iswc, '123456789123456');
is($work->type_id, 1);
is($work->edits_pending, 0);
is($work->artist_credit->name, 'Foo');
